defmodule FusionJWTAuthentication.JWKS_Strategy do
  @moduledoc """
  Contain strategy to fetch the JWKS if TokenJWKS is choosen as token_verifier.
  Automatically fetch the jwks when fusionauth application is started.
  Refetch the jwks once each time a kid isn't found inside the jwks.
  """

  require Logger

  alias __MODULE__.EtsCache
  alias Joken.Signer
  alias JokenJwks.{HttpFetcher, SignerMatchStrategy}

  @behaviour SignerMatchStrategy

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @spec init_opts(opts :: Keyword.t()) :: Keyword.t()
  def init_opts(opts) do
    base_url = Application.get_env(:fusion_jwt_authentication, :base_url)
    url = Keyword.get(opts, :jwks_url) || "#{base_url}/.well-known/jwks.json"

    Keyword.merge(opts, jwks_url: url)
  end

  @doc false
  def init(opts) do
    {:ok, %{opts: opts}, {:continue, :do_init}}
  end

  def handle_continue(:do_init, %{opts: opts}) do
    EtsCache.new()

    opts =
      Application.get_env(:joken_jwks, __MODULE__, [])
      |> Keyword.merge(opts)
      |> init_opts()

    url = opts[:jwks_url] || raise "No url set for fetching JWKS!"

    opts =
      opts
      |> Keyword.put(:jwks_url, url)

    fetch_signers(url, opts)
    {:noreply, %{}}
  end

  @impl SignerMatchStrategy
  def match_signer_for_kid(kid, opts) do
    opts =
      opts
      |> Keyword.put(:jwks_url, "https://fusionauth.test.well-known/jwks.json")

    with {:cache, [{:signers, signers}]} <- {:cache, EtsCache.get_signers()},
         {:signer, signer} when not is_nil(signer) <- {:signer, signers[kid]} do
      {:ok, signer}
    else
      {:signer, nil} ->
        fetch_signer_and_validate_kid(kid, opts)

      {:cache, []} ->
        {:error, :no_signers_fetched}

      err ->
        err
    end
  end

  def fetch_signer_and_validate_kid(kid, opts) do
    with true <- fetch_signers(opts[:jwks_url], opts),
         {:cache, [{:signers, signers}]} <- {:cache, EtsCache.get_signers()},
         {:signer, signer} when not is_nil(signer) <- {:signer, signers[kid]} do
    else
      _ -> {:error, :kid_does_not_match}
    end
  end

  @doc "Fetch signers with `JokenJwks.HttpFetcher`"
  def fetch_signers(url, opts) do
    opts = opts |> Keyword.put(:log_level, :debug)

    with {:ok, keys} <- HttpFetcher.fetch_signers(url, opts),
         {:ok, signers} <- validate_and_parse_keys(keys, opts) do
      Logger.debug("Fetched signers. #{inspect(signers)}")
      EtsCache.put_signers(signers)
    else
      {:error, _reason} = err ->
        Logger.debug("Failed to fetch signers. Reason: #{inspect(err)}")

      err ->
        Logger.debug("Unexpected error while fetching signers. Reason: #{inspect(err)}")
    end
  end

  defp validate_and_parse_keys(keys, opts) when is_list(keys) do
    Enum.reduce_while(keys, {:ok, %{}}, fn key, {:ok, acc} ->
      case parse_signer(key, opts) do
        {:ok, signer} -> {:cont, {:ok, Map.put(acc, key["kid"], signer)}}
        e -> {:halt, e}
      end
    end)
  end

  defp parse_signer(key, opts) do
    with {:kid, kid} when is_binary(kid) <- {:kid, key["kid"]},
         {:ok, alg} <- get_algorithm(key["alg"], opts[:explicit_alg]),
         {:ok, _signer} = res <- {:ok, Signer.create(alg, key)} do
      res
    else
      {:kid, _} -> {:error, :kid_not_binary}
      err -> err
    end
  rescue
    e ->
      Logger.debug("""
      Error while parsing a key entry fetched from the network.

      This should be investigated by a human.

      Key: #{inspect(key)}

      Error: #{inspect(e)}
      """)

      {:error, :invalid_key_params}
  end

  # According to JWKS spec (https://tools.ietf.org/html/rfc7517#section-4.4) the "alg"" claim
  # is not mandatory. This is why we allow this to be passed as a hook option.
  #
  # We give preference to the one provided as option
  defp get_algorithm(nil, nil), do: {:error, :no_algorithm_supplied}
  defp get_algorithm(_, alg) when is_binary(alg), do: {:ok, alg}
  defp get_algorithm(alg, _) when is_binary(alg), do: {:ok, alg}
  defp get_algorithm(_, _), do: {:error, :bad_algorithm}
end

defmodule FusionJWTAuthentication.JWKS_Strategy.EtsCache do
  @moduledoc "Simple ETS counter based state machine"

  @doc "Starts ETS cache"
  def new do
    __MODULE__ =
      :ets.new(__MODULE__, [
        :set,
        :public,
        :named_table,
        read_concurrency: true,
        write_concurrency: true
      ])
  end

  @doc "Loads fetched signers"
  def get_signers do
    :ets.lookup(__MODULE__, :signers)
  end

  @doc "Puts fetched signers"
  def put_signers(signers) do
    :ets.insert(__MODULE__, {:signers, signers})
  end
end

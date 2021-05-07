defmodule FusionJWTAuthentication.JWKS_Strategy do
  @moduledoc """
  Contain strategy to fetch the JWKS if Token is choosen as token_verifier.
  Automatically fetch the jwks when the application is started.
  Refetch the jwks once each time a kid isn't found inside the jwks.
  The jwks is cached in an ets table
  """

  require Logger

  alias __MODULE__.EtsCache
  alias Joken.Signer
  alias FusionJWTAuthentication.API.JWT

  use GenServer, restart: :permanent

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}, {:continue, :do_init}}
  end

  @impl true
  def handle_continue(:do_init, _state) do
    EtsCache.new()
    fetch_and_cache_signers()
    {:noreply, %{}}
  end

  @impl true
  def handle_call(:fetch_signers, _from, state) do
    fetch_and_cache_signers()
    {:reply, nil, state}
  end

  def match_signer_for_kid(kid) do
    with [{^kid, signer}] <- EtsCache.get_signer(kid) do
      {:ok, signer}
    else
      [] -> fetch_signer_and_match_kid(kid)
      err -> err
    end
  end

  def fetch_signer_and_match_kid(kid) do
    GenServer.call(__MODULE__, :fetch_signers, 10000)

    with [{^kid, signer}] <- EtsCache.get_signer(kid) do
      {:ok, signer}
    else
      _ -> {:error, :kid_does_not_match}
    end
  end

  @doc "Fetch signers and save them in the ets table"
  def fetch_and_cache_signers() do
    with {:ok, {_status_code, %{"keys" => keys}}} <- JWT.jwks(),
         {:ok, signers} <- validate_and_parse_keys(keys) do
      Logger.debug("Fetched signers. #{inspect(signers)}")
      EtsCache.put_signers(signers)
    else
      {:error, _reason} = err ->
        Logger.warn("#{__MODULE__} failed to fetch signers. Reason: #{inspect(err)}")

      err ->
        Logger.warn("#{__MODULE__} got an unexpected error while fetching signers. Reason: #{inspect(err)}")
    end
  end

  defp validate_and_parse_keys(keys) when is_list(keys) do
    Enum.reduce_while(keys, {:ok, []}, fn key, {:ok, acc} ->
      case parse_signer(key) do
        {:ok, signer} -> {:cont, {:ok, [{key["kid"], signer} | acc]}}
        e -> {:halt, e}
      end
    end)
  end

  defp parse_signer(key) do
    with {:kid, kid} when is_binary(kid) <- {:kid, key["kid"]},
         {:ok, alg} <- get_algorithm(key["alg"]),
         {:ok, _signer} = res <- {:ok, Signer.create(alg, key)} do
      res
    else
      {:kid, _} -> {:error, :kid_not_binary}
      err -> err
    end
  rescue
    e ->
      Logger.warn("""
      Error while parsing a key entry fetched from the network.

      This should be investigated by a human.

      Key: #{inspect(key)}

      Error: #{inspect(e)}
      """)

      {:error, :invalid_key_params}
  end

  defp get_algorithm(nil), do: {:error, :no_algorithm_supplied}
  defp get_algorithm(alg) when is_binary(alg), do: {:ok, alg}
  defp get_algorithm(_), do: {:error, :bad_algorithm}
end

defmodule FusionJWTAuthentication.JWKS_Strategy.EtsCache do
  @doc "Starts ETS cache"
  def new do
    __MODULE__ = :ets.new(__MODULE__, [:ordered_set, :protected, :named_table, read_concurrency: true])
  end

  @doc "Loads fetched signers"
  def get_signer(kid) do
    :ets.lookup(__MODULE__, kid)
  end

  @doc "Puts fetched signers"
  def put_signers(signers) do
    :ets.insert(__MODULE__, signers)
  end
end

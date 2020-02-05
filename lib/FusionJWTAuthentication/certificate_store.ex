defmodule FusionJWTAuthentication.CertificateStore do
  @moduledoc """
  Fetch certificate for certain application and store it in ets
  """
  use GenServer, restart: :permanent

  alias FusionJWTAuthentication.API.JWT

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec get_certificate(Ecto.UUID.t()) :: String.t() | nil
  def get_certificate(client_id) do
    case :ets.whereis(:certificate_store) do
      ref when is_reference(ref) ->
        case :ets.lookup(ref, client_id) do
          [] -> GenServer.call(__MODULE__, {:fetch_certificate, client_id})
          [{_key, result}] -> result
        end

      :undefined ->
        raise RuntimeError, message: "ETS table is missing"
    end
  end

  @impl true
  def init(_arg) do
    ref = :ets.new(:certificate_store, [:protected, {:read_concurrency, true}, :named_table])
    {:ok, %{certificate_store_ref: ref}}
  end

  @impl true
  def handle_call({:fetch_certificate, client_id}, _from, state) do
    case JWT.public_key(client_id) do
      nil ->
        {:reply, nil, state}

      key ->
        :ets.insert(state.certificate_store_ref, {client_id, key})
        {:reply, key, state}
    end
  end
end

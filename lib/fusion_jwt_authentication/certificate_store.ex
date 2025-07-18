defmodule FusionJWTAuthentication.CertificateStore do
  @moduledoc """
  Fetch certificate for certain application and store it in ets table to cache values
  """
  use GenServer, restart: :permanent

  alias FusionJWTAuthentication.API.JWT

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec get_certificate(JWT.uuid()) :: String.t() | nil
  def get_certificate(client_id) do
    case :ets.whereis(:certificate_store) do
      :undefined ->
        raise RuntimeError, message: "ETS table is missing"

      ref ->
        case :ets.lookup(ref, client_id) do
          [] -> GenServer.call(__MODULE__, {:fetch_certificate, client_id}, 10_000)
          [{_key, result}] -> result
        end
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

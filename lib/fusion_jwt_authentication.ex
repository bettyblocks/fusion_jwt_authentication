defmodule FusionJWTAuthentication do
  @moduledoc """
  Documentation for FusionJwtAuthentication.
  """
  use Application

  alias FusionJWTAuthentication.CertificateStore

  def start(_type, _args) do
    children = [CertificateStore]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

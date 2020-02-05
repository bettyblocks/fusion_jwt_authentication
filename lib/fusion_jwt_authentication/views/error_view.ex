defmodule FusionJWTAuthentication.ErrorView do
  @moduledoc false

  def render("401.json", _assigns) do
    %{
      status: 401,
      message: "Access denied"
    }
  end

  def render("404.json", _assigns) do
    %{
      status: 404,
      message: "Page not found"
    }
  end
end

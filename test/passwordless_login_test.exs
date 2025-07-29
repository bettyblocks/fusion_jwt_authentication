defmodule PasswordlessLoginTest do
  use ExUnit.Case

  alias FusionJWTAuthentication.API.PasswordlessLogin

  describe "start" do
    test "successfully should return code" do
      assert {:ok, {200, %{"code" => "CynAUMCHLxCCAWyHXOVWPQd8ZY0a6U0e3YpYkT0MNxs"}}} ==
               PasswordlessLogin.start("abc", "123", %{state: %{test: :test}})
    end

    test "error handling" do
      assert {:error, %Tesla.Env{status: 401}} ==
               PasswordlessLogin.start("abc", "123", %{status: 401})
    end
  end

  describe "login" do
    test "login successfully should return code" do
      assert {:ok, {200, %{"refreshToken" => "refreshToken", "state" => %{"prompt" => "prompt"}, "token" => "token"}}} ==
               PasswordlessLogin.login("logincodesuccess", "appid123")
    end

    test "error handling" do
      assert {:error, %Tesla.Env{status: 400}} ==
               PasswordlessLogin.login("invalid", "123")
    end

    test "not found" do
      assert {:error, %Tesla.Env{status: 404}} ==
               PasswordlessLogin.login("not_found", "123")
    end
  end
end

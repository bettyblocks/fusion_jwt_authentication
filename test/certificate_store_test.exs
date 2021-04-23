defmodule FusionJWTAuthentication.CertificateStoreTest do
  use ExUnit.Case

  alias FusionJWTAuthentication.CertificateStore
  alias FusionJWTAuthentication.Support.FusionGlobalAppCertificate

  test "module exists" do
    assert is_list(CertificateStore.module_info())
  end

  describe "certificate storage" do
    test "what happens if called without client_id" do
      assert nil == CertificateStore.get_certificate(nil)
    end

    test "what happens if called with incorrect client_id" do
      assert nil == CertificateStore.get_certificate("incorrect")
    end

    test "should return certificate is correct client_id" do
      assert FusionGlobalAppCertificate.public_key()["pem"] ==
               CertificateStore.get_certificate("11111111-1111-1111-1111-111111111111")
    end

    test "calls for a certain key should be cached and not recalculated" do
      assert timestamp = CertificateStore.get_certificate("time")
      assert timestamp == CertificateStore.get_certificate("time")
      assert timestamp == CertificateStore.get_certificate("time")
    end
  end
end

defmodule FusionJWTAuthentication.Support.FusionGlobalAppCertificate do
  @moduledoc false

  @public_key """
  -----BEGIN PUBLIC KEY-----
  MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuuzh0BmtJ67so6lwZYTK
  aZ3Nvn341mkHGkc6JmGGxMDmUqDZRAJ3VDmgjR/IwlQaqzcDnZ7CshPQsl4+/cTn
  a0WpB/iM6IaF0HL9VHj+9jFM1PXvwCFDaaYdYOJyccEOpCQgCabdDPWj/Gewdlhp
  59N9bSBhVGmK8bC2xyNSQtkt8LpqD/bnq2xSq9Mzsy+77Xc7S6EeUrcQtaPpxHP6
  JvHwFjT+KvVaxzWGVY0J32EQwlPEYQPZ1lgX6dRcMpddL5F0fRc6lT0jsZVIcIVY
  gHSs9EvR40Y/b3E3ic6w8HuzrGS+2tJbu100uR37DeKUaKz20yX0qYg7Om3rPDfm
  5QIDAQAB
  -----END PUBLIC KEY-----
  """

  @private_key """
  -----BEGIN PRIVATE KEY-----
  MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC67OHQGa0nruyj
  qXBlhMppnc2+ffjWaQcaRzomYYbEwOZSoNlEAndUOaCNH8jCVBqrNwOdnsKyE9Cy
  Xj79xOdrRakH+IzohoXQcv1UeP72MUzU9e/AIUNpph1g4nJxwQ6kJCAJpt0M9aP8
  Z7B2WGnn031tIGFUaYrxsLbHI1JC2S3wumoP9uerbFKr0zOzL7vtdztLoR5StxC1
  o+nEc/om8fAWNP4q9VrHNYZVjQnfYRDCU8RhA9nWWBfp1Fwyl10vkXR9FzqVPSOx
  lUhwhViAdKz0S9HjRj9vcTeJzrDwe7OsZL7a0lu7XTS5HfsN4pRorPbTJfSpiDs6
  bes8N+blAgMBAAECggEAAj9e57WnU1bTGZSr+UyDcomnM6coGsvgffxlQpjhmfQH
  0O6GLj8pWCXpPEkpjMyeFXjv3jFOff2nAL4JW9vGPI/13Fasuw8DBOKdESrzRdqJ
  5fWfEFxWByssJ0IRxjRgDLEygWs0NTeu5RYKFSIzA8qTM4C0KuOp/AX37KUMFCmr
  Cngcou6ZKknr6y6OxDYVU8ldMYU60Zl/+uwXISzThP4ImN2lIdKDxD3cPZjfLe8A
  pfJ5njaeUiz98R57fllp6LML3eqAbFqLnRtR3dClzxQlQsh7aKcMWktnFoosGlwW
  KbF1SviG5VFpKkl4vzP/qo+ul78k4s/Gy3pB7C46gQKBgQD38CCAcNThdvTuMam/
  IDJng4+f6FbM2W+wVjgvNaYyhjrcaNlmjAGkZ+JZnTc7PVxx6+YNMdPkzarBxOQu
  1KMVWyzNzy/D0e0whYBjXWKmZTLSL0Q2plYId7xAOt0bKAPpi4QIAV9o0lWmkI7c
  nCmYVINvmInefwfG10iwjHBDLQKBgQDBAOBgL6ALHV9I1FJn+qxC6a4cZmbMAZ86
  jOFQ40kBg58rbPRIhmBagy6h2cK2VKOeh3HBW0sSqgmP74VrePLlrmXEQUbdy3G/
  TjcD5NYl2aXOH22N3+BLUsA2WjrMMF2hRBZSpi14KJrkBeplsnR6mOwTwn3+I8oA
  +YtvLHtlmQKBgQDnznkEvPk7hzV+Ua5rxBV8FFO+5MHqqkwzKJlFAjrNuBPmKJ1B
  tBqA9KN6t3OBDmCVHkGrCnAa1nMU0Rmp8yI6gFEGZvQ4d9fz6o1b2V63RZxbSNfU
  5HVBW3kE8EPy9Nmbi9Y4idgDL8vme/clqVd2VWXBe3NDM684p+UNM3BuTQKBgCkZ
  iq5w9d/oDVZxAGtsEirdoFoj5FglMEdDoOecvvs3kDmrJgobs4ES1mdY/AHf3Efy
  B+NpEX+T/h1MoFjWlMMcdEdqrzCkFkDq4wRNQt0kkA5o2uePeTARGyV36XV6BzZE
  TYykHqKr4vAT4mptqihBUGSU0kfAT1AN1AeErXJhAoGBANAh/48ropxLhxLVzfts
  XOjFWV01JNxzOqhp7v8719u7X/L2DTxRoveBdojCSzSzCK+Frce7hFJVXG4cgOsF
  5r1xjipArSRmkJ/vgLRKa6FpPuLw/aJBQ9vIihUPOTULVJnwiiggsboO/rWGPBHC
  wSlex75trENCAFI0i3NOxpeC
  -----END PRIVATE KEY-----
  """

  def public_key, do: %{"pem" => @public_key}

  def private_key, do: %{"pem" => @private_key}
end

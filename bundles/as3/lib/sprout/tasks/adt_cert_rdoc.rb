module Sprout
class ADTCertTask < ToolTask
# Using -certificate option as default.
def certificate=(boolean)
  @certificate = boolean
end

# The string assigned as the common name of the new certificate.
def cn=(string)
  @cn = string
end

# Astring assigned as the organizational unit issuing the certificate.
def ou=(string)
  @ou = string
end

# A string assigned as the organization issuing the certificate.
def o=(string)
  @o = string
end

# A two-letter ISO-3166 country code. A certificate is not generated if an invalid code is supplied.
def c=(string)
  @c = string
end

# The type of key to use for the certificate, either "1024-RSA" or "2048-RSA".
def keytype=(string)
  @keytype = string
end

# The path for the certificate file to be generated.
def keystore=(file)
  @keystore = file
end

# The password for the new certificate. The password is required when signing AIR files with this certificate.
def keypass=(string)
  @keypass = string
end

end
end

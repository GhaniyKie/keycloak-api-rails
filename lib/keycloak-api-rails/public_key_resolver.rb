module Keycloak
  class PublicKeyResolver
    def initialize(http_client, realm_id)
      @realm_id    = realm_id
      @http_client = http_client
    end

    def find_public_keys
      # JSON::JWK::Set.new(@http_client.get(@realm_id, "protocol/openid-connect/certs")["keys"])
      # OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\n #{@http_client.get(@realm_id, '')['public_key']} \n-----END PUBLIC KEY-----\n")
      puts @http_client.get(@realm_id, '')
    end
  end
end

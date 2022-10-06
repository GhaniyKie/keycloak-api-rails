module Keycloak
  class Service
    def initialize(key_resolver)
      @key_resolver                          = key_resolver
      @skip_paths                            = Keycloak.config.skip_paths
      @logger                                = Keycloak.config.logger
      @token_expiration_tolerance_in_seconds = Keycloak.config.token_expiration_tolerance_in_seconds
    end

    # def decode_and_verify(token)
    #   if token.nil? || token&.empty?
    #     raise TokenError.no_token(token)
    #   else
    #     public_key    = @key_resolver.find_public_keys
    #     # decoded_token = JSON::JWT.decode(token, public_key)
    #     decoded_token = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
    #     if expired?(decoded_token)
    #       raise TokenError.expired(token)
    #     else
    #       # decoded_token.verify!(public_key)
    #       decoded_token
    #     end
    #   end
    # # rescue JSON::JWT::VerificationFailed => e
    #   # raise TokenError.verification_failed(token, e)
    # # rescue JSON::JWK::Set::KidNotFound => e
    #   # raise TokenError.verification_failed(token, e)
    # # rescue JSON::JWT::InvalidFormat
    # rescue JWT::DecodeError => e
    #   raise TokenError.invalid_format(token, e)
    # end
    def decode_and_verify(token)
      public_key    = @key_resolver.find_public_keys
      # decoded_token = JSON::JWT.decode(token, public_key)
      decoded_token = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
      if expired?(decoded_token)
        raise TokenError.expired(token)
      else
        # decoded_token.verify!(public_key)
        decoded_token
      end
    rescue JWT::DecodeError => e
      raise TokenError.invalid_format(token, e)
    end

    def read_token(uri, headers)
      Helper.read_token_from_query_string(uri) || Helper.read_token_from_headers(headers)
    end

    def need_authentication?(method, path, headers)
      !should_skip?(method, path) && !is_preflight?(method, headers)
    end

    private

    def should_skip?(method, path)
      method_symbol = method&.downcase&.to_sym
      skip_paths    = @skip_paths[method_symbol]
      !skip_paths.nil? && !skip_paths.empty? && !skip_paths.find_index { |skip_path| skip_path.match(path) }.nil?
    end

    def is_preflight?(method, headers)
      method_symbol = method&.downcase&.to_sym
      method_symbol == :options && !headers['HTTP_ACCESS_CONTROL_REQUEST_METHOD'].nil?
    end

    def expired?(token)
      token_expiration = Time.at(token.first['exp']).to_datetime
      token_expiration < Time.now + @token_expiration_tolerance_in_seconds.seconds
    end
  end
end

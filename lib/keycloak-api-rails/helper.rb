module Keycloak
  class Helper
    CURRENT_USER_ID_KEY          = 'keycloak:keycloak_id'.freeze
    CURRENT_AUTHORIZED_PARTY_KEY = 'keycloak:authorized_party'.freeze
    CURRENT_USER_EMAIL_KEY       = 'keycloak:email'.freeze
    CURRENT_USER_LOCALE_KEY      = 'keycloak:locale'.freeze
    CURRENT_USER_ATTRIBUTES      = 'keycloak:attributes'.freeze
    ROLES_KEY                    = 'keycloak:roles'.freeze
    RESOURCE_ROLES_KEY           = 'keycloak:resource_roles'.freeze
    DECODED_TOKEN_KEY            = 'keycloak:decoded_token'.freeze
    QUERY_STRING_TOKEN_KEY       = 'authorizationToken'.freeze

    def self.current_user_id(env)
      env[CURRENT_USER_ID_KEY]
    end

    def self.assign_current_user_id(env, decoded)
      env[CURRENT_USER_ID_KEY] = decoded['sub']
    end

    def self.decoded_token
      env[DECODED_TOKEN_KEY]
    end

    def self.assign_decoded_token(env, decoded)
      env[DECODED_TOKEN_KEY] = decoded
    end

    def self.current_authorized_party
      env[CURRENT_AUTHORIZED_PARTY_KEY]
    end

    def self.assign_current_authorized_party(env, decoded)
      env[CURRENT_AUTHORIZED_PARTY_KEY] = decoded['azp']
    end

    def self.current_user_email
      env[CURRENT_USER_EMAIL_KEY]
    end

    def self.assign_current_user_email(env, decoded)
      env[CURRENT_USER_EMAIL_KEY] = decoded['email']
    end

    def self.current_user_locale
      env[CURRENT_USER_LOCALE_KEY]
    end

    def self.assign_current_user_locale(env, decoded)
      env[CURRENT_USER_LOCALE_KEY] = decoded['locale']
    end

    def self.current_user_roles
      env[ROLES_KEY]
    end

    def self.assign_realm_roles(env, decoded)
      env[ROLES_KEY] = decoded.dig('realm_access', 'roles')
    end

    def self.current_resource_roles
      env[RESOURCE_ROLES_KEY]
    end

    def self.assign_resource_roles(env, decoded)
      env[RESOURCE_ROLES_KEY] = decoded.fetch('resource_access', {}).each_with_object({}) do |(name, resource_attributes), resource_roles|
        resource_roles[name] = resource_attributes.fetch('roles', [])
      end

      # todo:
      # env[RESOURCE_ROLES_KEY] = token.fetch('resource_access', {}).transform_values { |resource_attributes| resource_attributes.fetch('roles', []) }
    end

    def self.assign_current_user_custom_attributes(env, decoded, attribute_names)
      env[CURRENT_USER_ATTRIBUTES] = decoded.select { |key, _value| attribute_names.include?(key) }
    end

    def self.current_user_custom_attributes
      env[CURRENT_USER_ATTRIBUTES]
    end

    def self.read_token_from_query_string(uri)
      parsed_uri         = URI.parse(uri)
      query              = URI.decode_www_form(parsed_uri.query || '')
      query_string_token = query.detect { |param| param.first == QUERY_STRING_TOKEN_KEY }
      query_string_token&.second
    end

    def self.create_url_with_token(uri, token)
      uri       = URI(uri)
      params    = URI.decode_www_form(uri.query || '').reject do |query_string|
        query_string.first == QUERY_STRING_TOKEN_KEY
      end
      params << [QUERY_STRING_TOKEN_KEY, token]
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end

    def self.read_token_from_headers(headers)
      headers['HTTP_AUTHORIZATION']&.gsub(/^Bearer /, '') || ''
    end

    def self.decoded_token_attribute(attribute_name)
      attribute = decoded_token.select { |attr| attr[attribute_name] }

      raise TokenError.attribute_not_found decoded_token if attribute.blank?

      attribute
    end
  end
end

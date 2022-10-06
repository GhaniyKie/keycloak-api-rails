module Keycloak
  class Helper
    CURRENT_USER_ID_KEY          = 'keycloak:keycloak_id'
    CURRENT_AUTHORIZED_PARTY_KEY = 'keycloak:authorized_party'
    CURRENT_USER_EMAIL_KEY       = 'keycloak:email'
    CURRENT_USER_LOCALE_KEY      = 'keycloak:locale'
    CURRENT_USER_ATTRIBUTES      = 'keycloak:attributes'
    ROLES_KEY                    = 'keycloak:roles'
    RESOURCE_ROLES_KEY           = 'keycloak:resource_roles'
    TOKEN_KEY                    = 'keycloak:token'
    QUERY_STRING_TOKEN_KEY       = 'authorizationToken'

    def self.current_user_id(env)
      env[CURRENT_USER_ID_KEY]
    end

    def self.assign_current_user_id(env, token)
      env[CURRENT_USER_ID_KEY] = token['sub']
    end

    def self.keycloak_token(env)
      env[TOKEN_KEY]
    end

    def self.assign_keycloak_token(env, token)
      env[TOKEN_KEY] = token
    end

    def self.current_authorized_party(env)
      env[CURRENT_AUTHORIZED_PARTY_KEY]
    end

    def self.assign_current_authorized_party(env, token)
      env[CURRENT_AUTHORIZED_PARTY_KEY] = token['azp']
    end

    def self.current_user_email(env)
      env[CURRENT_USER_EMAIL_KEY]
    end

    def self.assign_current_user_email(env, token)
      env[CURRENT_USER_EMAIL_KEY] = token['email']
    end

    def self.current_user_locale(env)
      env[CURRENT_USER_LOCALE_KEY]
    end

    def self.assign_current_user_locale(env, token)
      env[CURRENT_USER_LOCALE_KEY] = token['locale']
    end

    def self.current_user_roles(env)
      env[ROLES_KEY]
    end

    def self.assign_realm_roles(env, token)
      env[ROLES_KEY] = token.dig('realm_access', 'roles')
    end

    def self.current_resource_roles(env)
      env[RESOURCE_ROLES_KEY]
    end

    def self.assign_resource_roles(env, token)
      env[RESOURCE_ROLES_KEY] = token.fetch('resource_access', {}).each_with_object({}) do |(name, resource_attributes), resource_roles|
        resource_roles[name] = resource_attributes.fetch('roles', [])
      end

      # todo:
      # env[RESOURCE_ROLES_KEY] = token.fetch('resource_access', {}).transform_values { |resource_attributes| resource_attributes.fetch('roles', []) }
    end

    def self.assign_current_user_custom_attributes(env, token, attribute_names)
      env[CURRENT_USER_ATTRIBUTES] = token.select { |key, _value| attribute_names.include?(key) }
    end

    def self.current_user_custom_attributes(env)
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

    def self.token_attribute(env, attribute_name)
      decoded_token = Keycloak.service.decode_and_verify(keycloak_token(env))
      attribute = decoded_token.select { |attr| attr[attribute_name] }

      raise TokenError.attribute_not_found token if attribute.blank?

      attribute
    end
  end
end

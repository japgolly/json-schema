require_relative 'extends'

module JSON
  class Schema
    class AdditionalPropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})

        if data.is_a?(Hash)
          extra_properties = data.keys

          extra_properties = remove_valid_properties(extra_properties, current_schema, validator)

          # TODO extended additionalProperties aren't currently validated
          if current_schema.schema['additionalProperties'] == false && !extra_properties.empty?
            message = "The property '#{build_fragment(fragments)}' contains additional properties #{extra_properties.inspect} outside of the schema when none are allowed"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          elsif current_schema.schema['additionalProperties'].is_a?(Hash)
            extra_properties.each do |key|
              schema = JSON::Schema.new(current_schema.schema['additionalProperties'],current_schema.uri,validator)
              fragments << key
              schema.validate(data[key],fragments,options)
              fragments.pop
            end
          end

        end
      end

      def self.remove_valid_properties(extra_properties, current_schema, validator)

          if current_schema.schema['properties']
            extra_properties = extra_properties - current_schema.schema['properties'].keys
          end

          if current_schema.schema['patternProperties']
            current_schema.schema['patternProperties'].each_key do |key|
              r = Regexp.new(key)
              extras_clone = extra_properties.clone
              extras_clone.each do |prop|
                if r.match(prop)
                  extra_properties = extra_properties - [prop]
                end
              end
            end
          end

          if schemas= current_schema.schema['extends']
            schemas = [schemas] if !schemas.is_a?(Array)
            schemas.each do |schema_value|
              temp_uri,extended_schema= JSON::Schema::ExtendsAttribute.get_extended_uri_and_schema(schema_value, current_schema, validator)
              if extended_schema
                extra_properties= remove_valid_properties(extra_properties, extended_schema, validator)
              end
            end
          end

          extra_properties
      end
    end
  end
end

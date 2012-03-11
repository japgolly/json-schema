require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class ExtendsAndAdditionalPropertiesTest < Test::Unit::TestCase

  def assert_validity(valid, schema_name, data)
    file = File.expand_path("../schemas/#{schema_name}.schema.json",__FILE__)
    errors = JSON::Validator.fully_validate file, data
    send (valid ? :assert_equal : :refute_equal), [], errors, "Schema should be #{valid ? :valid : :invalid}"
  end

  def assert_valid(schema_name, data) assert_validity true, schema_name, data end
  def refute_valid(schema_name, data) assert_validity false, schema_name, data end

  %w[outer1 outer2 outer3].each do |schema_name|
    class_eval <<-EOB
      def test_#{schema_name}_valid_outer
        assert_valid '#{schema_name}', "outerC"=>true
      end

      def test_#{schema_name}_valid_outer_extended
        assert_valid '#{schema_name}', "innerA"=>true
      end

      def test_#{schema_name}_valid_inner
        assert_valid '#{schema_name}', "outerB"=>[{"innerA"=>true}]
      end

      def test_#{schema_name}_invalid_outer
        refute_valid '#{schema_name}', "whaaaaat"=>true
      end

      def test_#{schema_name}_invalid_inner
        refute_valid '#{schema_name}', "outerB"=>[{"whaaaaat"=>true}]
      end
    EOB
  end

end

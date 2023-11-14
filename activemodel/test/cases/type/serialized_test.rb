# frozen_string_literal: true

require "cases/helper"

module ActiveModel
  module Type
    class SerializedTest < ActiveModel::TestCase
      class Coder
        def self.dump(value)
          "dump(#{value})"
        end

        def self.load(value)
          "load(#{value})"
        end
      end

      class BrokenCoder
        def self.dump(value)
          raise StandardError
        end

        def self.load(value)
          raise StandardError
        end
      end

      def test_type
        type = Type::Serialized.new(coder: Coder)
        assert_equal :serialized, type.type
      end

      def test_type_without_coder
        assert_raises(ArgumentError) { Type::Serialized.new }
      end

      def test_type_cast
        type = Type::Serialized.new(coder: Coder)
        assert_equal "load(foo)", type.cast("foo")
        assert_nil type.cast(nil)
      end

      def test_type_cast_with_instance
        type = Type::Serialized.new(coder: Coder)
        instance = Coder.new
        assert_equal instance, type.cast(instance)
      end

      def test_type_cast_with_error
        type = Type::Serialized.new(coder: BrokenCoder)
        assert_nil type.cast("foo")
      end

      def test_type_cast_for_database
        type = Type::Serialized.new(coder: Coder)
        assert_equal "dump(foo)", type.serialize("foo")
      end

      def test_type_cast_for_database_with_yaml
        type = Type::Serialized.new(coder: YAML)
        assert_equal "--- foo\n", type.serialize("foo")
      end

      def test_type_cast_for_database_with_error
        type = Type::Serialized.new(coder: BrokenCoder)
        assert_nil type.serialize("foo")
      end

      def test_type_cast_from_database
        type = Type::Serialized.new(coder: Coder)
        assert_equal "load(foo)", type.deserialize("foo")
      end

      def test_type_cast_from_database_with_yaml
        type = Type::Serialized.new(coder: YAML)
        assert_equal "foo", type.deserialize("--- foo\n")
      end

      def test_type_cast_from_database_with_error
        type = Type::Serialized.new(coder: BrokenCoder)
        assert_nil type.deserialize("foo")
      end

      def test_equal
        assert_equal Type::Serialized.new(coder: Coder), Type::Serialized.new(coder: Coder)
        assert_not_equal Type::Serialized.new(coder: Coder), Type::Serialized.new(coder: BrokenCoder)
      end
    end
  end
end

# frozen_string_literal: true

module ActiveModel
  module Type
    class Serialized < Value
      attr_reader :coder

      def initialize(**args)
        @coder = args.delete(:coder) || raise(ArgumentError, "You must specify a coder")
        super
      end

      def type
        :serialized
      end

      def serialize(value)
        coder.dump(value)
      rescue
      end

      def ==(other)
        super && coder == other.coder
      end

      private
        def cast_value(value)
          case value
          when coder then value
          else coder.load(value)
          end
        rescue
        end
    end
  end
end

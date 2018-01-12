# frozen_string_literal: true

module Decidim
  module Parsers
    # Base class used for any content parser.
    class Base
      # Implement this in your parser
      def parse(content)
        content
      end

      def with_context(context)
        @context = context
        self
      end

      def context
        raise "This parser needs a context to run" unless @context
        @context
      end
    end
  end
end

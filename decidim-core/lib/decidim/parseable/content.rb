# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Parseable
    # Shared behaviour for parseable content on models.
    module Content
      extend ActiveSupport::Concern

      included do
        class_attribute :parsed_content_attribute_names, :parse_content_options

        before_save :parse_content
      end

      module ClassMethods
        def parses_content(*attr_names)
          options = attr_names.extract_options!
          setup_parses_content!(options)

          attr_names = attr_names.map(&:to_sym)
          self.parsed_content_attribute_names = attr_names
        end

        def parse_content_class
          @parse_content_class ||= begin
            klass = if const_defined?(:ParseContentRunner, false)
                      const_get(:ParseContentRunner, false)
                    else
                      const_set(:ParseContentRunner, Class.new(Decidim::Parsers::Runner))
                    end

            klass = klass.new(Decidim.content_parsers)
            klass.configure do |config|
              config.skip_on = proc { |subject, _attr_name, runner|
                subject.parse_content_options[:skip] &&
                  subject.parse_content_options[:skip].include?(runner.class.name)
              }
            end

            klass
          end
        end

        protected

        def setup_parses_content!(options)
          self.parsed_content_attribute_names = []
          self.parse_content_options = options
        end
      end

      def parse_content
        return if self.parsed_content_attribute_names.empty?

        self.parsed_content_attribute_names.each do |attr_name|
          send("#{attr_name}=", self.class.parse_content_class.with_subject(self).run_on(attr_name))
        end
      end
    end
  end
end

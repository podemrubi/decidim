module Decidim
  module Parsers
    class Runner
      attr_reader :parsers

      def initialize(parsers = [])
        @parsers = parsers
      end

      def config
        @config ||= RunnerConfig.new
        yield @config if block_given?
        @config
      end
      alias configure config

      def run_on(attr_name)
        parsers_chain.reduce(subject.send(attr_name)) do |subj, parser|
          if config.skip?(subject, attr_name, parser)
            subj
          else
            parser.with_context(subject).parse(subj)
          end
        end
      end

      def with_subject(subject)
        @subject = subject
        self
      end

      def subject
        raise "The runner needs a subject where run" unless @subject
        @subject
      end

      private

      def parsers_chain
        @parsers_chain ||= parsers.map do |klass|
          klass.constantize.new
        end
      end
    end
  end
end

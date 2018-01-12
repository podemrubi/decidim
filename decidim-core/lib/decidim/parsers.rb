# frozen_string_literal: true

module Decidim
  module Parsers
    autoload :Base, "decidim/parsers/base"
    autoload :ContentParser, "decidim/parsers/content_parser"
    autoload :Runner, "decidim/parsers/runner"
    autoload :RunnerConfig, "decidim/parsers/runner_config"
  end
end

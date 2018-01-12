module Decidim
  module Parsers
    module Content
      class MentionParser < ContentParser
        def parse(content)
          return content if content.empty?

          content.gsub(/(?:^|\s)@([a-z0-9]\w*)/) do |match|
            if (user = Decidim::User.find_by(nickname: Regexp.last_match[1]))
              presenter = Decidim::UserPresenter.new(user)
              %( <a href="#{presenter.profile_path}">#{presenter.nickname}</a>)
            else
              match
            end
          end
        end
      end
    end
  end
end

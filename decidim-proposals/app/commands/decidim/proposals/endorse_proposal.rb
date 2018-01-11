# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user endorses a proposal.
    class EndorseProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      # current_group_id- (optional) The current_grup that is endorsing the Proposal.
      def initialize(proposal, current_user, current_group_id = nil)
        @proposal = proposal
        @current_user = current_user
        @current_group_id = current_group_id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        endorsement = build_proposal_endorsement
        endorsement.save ? broadcast(:ok, endorsement) : broadcast(:invalid)
      end

      private

      def build_proposal_endorsement
        endorsement = @proposal.endorsements.build(author: @current_user)
        if @current_group_id.present?
          endorsement.user_group = @current_user.user_groups.verified.find(@current_group_id)
        end
        endorsement
      end
    end
  end
end

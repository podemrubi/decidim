# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateAssemblyAdmin < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - The Assembly that will hold the
        #   user role
        def initialize(form, current_user, assembly)
          @form = form
          @current_user = current_user
          @assembly = assembly
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          ActiveRecord::Base.transaction do
            create_or_invite_user
            create_role
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:email, :taken)
          broadcast(:invalid)
        end

        private

        attr_reader :form, :assembly, :current_user, :user

        def create_role
          Decidim::AssemblyUserRole.find_or_create_by!(
            role: form.role.to_sym,
            user: user,
            assembly: @assembly
          )
        end

        def create_or_invite_user
          @user ||= existing_user || new_user
        end

        def existing_user
          return @existing_user if defined?(@existing_user)

          @existing_user = User.where(
            email: form.email,
            organization: assembly.organization
          ).first

          if @existing_user && !@existing_user.invitation_accepted?
            InviteUserAgain.call(@existing_user, invitation_instructions)
          end

          @existing_user
        end

        def new_user
          @new_user ||= InviteUser.call(user_form) do
            on(:ok) do |user|
              return user
            end
          end
        end

        def user_form
          OpenStruct.new(name: form.name,
                         email: form.email.downcase,
                         organization: assembly.organization,
                         admin: false,
                         invited_by: current_user,
                         invitation_instructions: invitation_instructions)
        end

        def invitation_instructions
          return "invite_admin" if form.role == "admin"
          "invite_collaborator"
        end
      end
    end
  end
end

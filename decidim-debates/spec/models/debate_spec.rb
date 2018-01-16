# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Debate do
  subject { debate }

  let(:debate) { build :debate }

  it { is_expected.to be_valid }

  include_examples "has feature"
  include_examples "has category"

  context "without a title" do
    let(:debate) { build :debate, title: nil }

    it { is_expected.not_to be_valid }
  end
end

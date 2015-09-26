require 'spec_helper'

describe Missle do
  it 'has a version number' do
    expect(Missle::VERSION).not_to be nil
  end

  it 'loads the Command class' do
    expect(Missle::Command).not_to be nil
  end
end

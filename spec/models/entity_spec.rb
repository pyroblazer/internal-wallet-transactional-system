require 'rails_helper'

RSpec.describe Entity, type: :model do
  it { should belong_to(:entity) }
end
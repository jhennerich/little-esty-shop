require 'rails_helper'

RSpec.describe BulkDiscount do

  describe "relations" do
    it { should belong_to :merchant }
  end

  describe "validations" do
    it { should validate_presence_of :discount }
    it { should validate_presence_of :threshold }
  end

end

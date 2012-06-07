require 'spec_helper'

module Fedex
  describe Address do
    describe "ship service for label" do
      let(:fedex) { Shipment.new(fedex_credentials) }

      context "valid address", :vcr do
        let(:address) do
          {
            :street      => "5 Elm Street",
            :city        => "Norwalk",
            :state       => "CT",
            :postal_code => "06850",
            :country     => "USA"
          }
        end

        let(:options) do
          { :address => address }
        end

        it "validates the address" do
          fedex.validate_address(options)
        end
      end

    end
  end
end
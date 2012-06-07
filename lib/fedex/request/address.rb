require 'fedex/request/base'
require 'fedex/address'
require 'fileutils'

module Fedex
  module Request
    class Address < Base
      def initialize(credentials, options={})
        requires!(options, :address)
        @credentials = credentials
        @address     = options[:address]
      end

      def process_request
        api_response = self.class.post(api_url, :body => build_xml)
        puts api_response if @debug == true
        response = parse_response(api_response)
        if success?(response)
          puts response
        else
          error_message = if response[:address_validation_reply]
            [response[:address_validation_reply][:notifications]].flatten.first[:message]
          else
            api_response["Fault"]["detail"]["fault"]["reason"]
          end rescue $1
          raise RateError, error_message
        end
      end

      private

      # Build xml Fedex Web Service request
      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.AddressValidationRequest(:xmlns => "http://fedex.com/ws/addressvalidation/v2"){
            add_web_authentication_detail(xml)
            add_client_detail(xml)
            add_version(xml)
            add_address_to_validate(xml)
          }
        end
        builder.doc.root.to_xml
      end

      def add_address_to_validate(xml)
        xml.AddressToValidate{
          xml.Address{
            xml.StreetLines         @address[:street]
            xml.City                @address[:city]
            xml.StateOrProvinceCode @address[:state]
            xml.PostalCode          @address[:postal_code]
            xml.CountryCode         @address[:country]
          }
        }
      end

      # # Add web authentication detail information(key and password) to xml request
      # def add_web_authentication_detail(xml)
      #   xml.WebAuthenticationDetail{
      #     xml.UserCredential {
      #       xml.WebAuthenticationCredential{
      #         xml.Key @credentials.key
      #         xml.Password @credentials.password
      #       }
      #     }
      #   }
      # end

      def service_id
        'aval'
      end

      # Successful request
      def success?(response)
        response[:process_shipment_reply] &&
          %w{SUCCESS WARNING NOTE}.include?(response[:process_shipment_reply][:highest_severity])
      end

    end
  end
end
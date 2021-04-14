require 'nokogiri'

module ForceUnspecified
  module Manipulations
    class RequestedAuthnContext
      def initialize(xml, _request)
        @xml = xml
      end

      def result
        request = Nokogiri::XML(@xml)
        request.search('samlp|RequestedAuthnContext').each(&:remove)
        request.to_xml
      end
    end
  end
end

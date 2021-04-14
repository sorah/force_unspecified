require 'nokogiri'

module ForceUnspecified
  module Manipulations
    class RequestedAuthnContext
      def initialize(xml, _request)
        @xml = xml
      end

      def result
        request = Nokogiri::XML(@xml)
        begin
          request.search('samlp|RequestedAuthnContext').each(&:remove)
        rescue Nokogiri::XML::XPath::SyntaxError; nil # ignore undefined namespace prefix
        request.to_xml
      end
    end
  end
end

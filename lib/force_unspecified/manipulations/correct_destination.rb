require 'nokogiri'

module ForceUnspecified
  module Manipulations
    class CorrectDestination
      def initialize(xml, request)
        @xml = xml
        @request = request
      end

      def result
        @xml.gsub("#{@request.request.base_url}#{@request.request.path}", @request.next_hop)
      end
    end
  end
end

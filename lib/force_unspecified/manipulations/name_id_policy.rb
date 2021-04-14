module ForceUnspecified
  module Manipulations
    class NameIDPolicy
      def initialize(xml, _request)
        @xml = xml
      end

      def result
        @xml
          .gsub(/(['"])urn:oasis:names:tc:SAML:1.1:nameid-format:.+?(["'])/, '\1urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified\2')
      end
    end
  end
end

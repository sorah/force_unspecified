require 'rack'
require 'zlib'

module ForceUnspecified
  class App
    def self.call(env)
      new(env).call
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    attr_reader :request

    def call
      next_hop = URI.decode_www_form_component(request.path.sub(%r{^/}, ''))
      if next_hop.empty?
        return index()
      end
      unless saml_request_original
        return [400, {'Content-Type' => 'text/plain'}, ["SAMLRequest is missing\n"]]
      end

      modified_saml_request = saml_request.
        gsub(/(['"])urn:oasis:names:tc:SAML:1.1:nameid-format:.+?(["'])/, '\1urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified\2')
      param = encode_saml_request(modified_saml_request)

      [302, {'Location' => "#{next_hop}?SAMLRequest=#{param}"}, ['']]
    end

    def index
      [200, {'Content-Type' => 'text/plain'}, [<<-EOF]]
https://github.com/sorah/force_unspecified
Modifies received SAMLRequest to force 'unspecified' as a requested NameIDPolicy, and redirects to a SAML consumer URL.

Usage: #{request.base_url}/https://login.example.org/saml?SAMLRequest=xxxxx
      EOF
    end

    def saml_request_original
      request.params['SAMLRequest']
    end

    def decode_saml_request
      return nil unless saml_request_original
      decoded = saml_request_original.unpack('m*')[0]
      begin
        Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(decoded)
      rescue
        decoded
      end
    end

    def encode_saml_request(string = saml_request())
      URI.encode_www_form_component [Zlib::Deflate.deflate(string, 9)[2..-5]].pack('m*').gsub(/\r?\n/, '')
    end

    def saml_request
      @saml_request ||= decode_saml_request
    end
  end
end

require 'rack'
require 'zlib'
require 'uri'

require 'force_unspecified/manipulations/name_id_policy'
require 'force_unspecified/manipulations/requested_authn_context'
require 'force_unspecified/manipulations/correct_destination'

module ForceUnspecified
  class ManipulationNameError < NameError; end

  class App
    def self.call(env)
      new(env).call
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    attr_reader :request

    def call
      if next_hop.empty?
        return index()
      end
      unless saml_request_original
        return [400, {'Content-Type' => 'text/plain'}, ["SAMLRequest is missing\n"]]
      end

      if allowed_next_hop_list && !allowed_next_hop_list.include?(next_hop_host)
        return [403, {'Content-Type' => 'text/plain'}, ["next hop unallowed\n"]]
      end

      modified_saml_request = manipulations.inject(saml_request) { |r,i| i.new(r, self).result }
      param = encode_saml_request(modified_saml_request)

      [302, {'Location' => "#{next_hop}?SAMLRequest=#{param}"}, ['']]
    rescue ManipulationNameError => e
      return [400, {'Content-Type' => 'text/plain'}, ["#{e.message}\n"]]
    end

    def index
      [200, {'Content-Type' => 'text/plain'}, [<<-EOF]]
https://github.com/sorah/force_unspecified

Usage: #{request.base_url}/manipulate/NameIDPolicy/login.example.org/saml?SAMLRequest=xxxxx
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

    def next_hop
      return @next_hop if defined? @next_hop

      next_hop = if request.path.start_with?('/manipulate/')
                   URI.decode_www_form_component(request.path.sub(%r{^/manipulate/[^/]+/}, 'https://'))
                 else # backward compatibility
                   URI.decode_www_form_component(request.path.sub(%r{^/}, ''))
                 end
      @next_hop = next_hop.empty? ? nil : next_hop
    end

    def manipulations
      @manipulations ||= if request.path.start_with?('/manipulate/')
                           request.path.match(%r{^/manipulate/([^/]+?)/})&.then{ |_| _[1] } || ''
                         else # backward compatibility
                           'NameIDPolicy'
                         end.split(?,).map do |name|
                           Manipulations.const_get(name.to_sym, false)
                         rescue NameError => e
                           raise ManipulationNameError, e.message
                         end.compact + [Manipulations::CorrectDestination]
    end

    def next_hop_host
      URI.parse(next_hop).host
    rescue URI::InvalidURIError
      nil
    end

    def allowed_next_hop_list
      return @allowed_next_hop_list if defined? @allowed_next_hop_list
      @allowed_next_hop_list = ENV['ALLOWED_NEXT_HOP_LIST']&.split(?,)
    end
  end
end

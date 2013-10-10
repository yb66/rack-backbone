require "rack/backbone/version"
require "rack/jquery/helpers"

# @see http://rack.github.io/
module Rack

  # Backbone CDN script tags and fallback in one neat package.
  class Backbone
    include Rack::JQuery::Helpers

    # Current file name of fallback.
    BACKBONE_FILE_NAME = "backbone-#{BACKBONE_VERSION}-min.js"

    # Fallback source map file name without version.
    # Because the main script doesn't call
    # a versioned file.
    BACKBONE_SOURCE_MAP_UNVERSIONED = "backbone-min.map"

    # Fallback source map file name.
    BACKBONE_SOURCE_MAP = "backbone-#{BACKBONE_VERSION}-min.map"


    # Namespaced CDNs for convenience.
    module CDN

      # Script tags for the Cloudflare CDN
      CLOUDFLARE = "//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.0.0/backbone-min.js"

      # Script tags for the jsdelivr CDN
      JSDELIVR = "//cdn.jsdelivr.net/backbonejs/1.0.0/backbone-min.js"

    end


    # Default options hash for the middleware.
    DEFAULT_OPTIONS = {
      :http_path => "/js"
    }


    # This javascript checks if the Backbone object has loaded. If not, that most likely means the CDN is unreachable, so it uses the local minified Backbone.
    FALLBACK_TOP = <<STR
<script type="text/javascript">
  if (typeof Backbone == 'undefined') {
    document.write(unescape("%3Cscript src='
STR

    FALLBACK_BOTTOM = <<STR
' type='text/javascript'%3E%3C/script%3E"))
  };
</script>
STR

    # @param [Hash] env The rack env hash.
    # @option options [Symbol] organisation Choose which CDN to use, either :jsdelivr, or :cloudflare (the default). This will override anything set via the `use` statement.
    # @return [String] The HTML script tags to get the CDN.
    def self.cdn( env, options={}  )
      if env.nil? || env.has_key?(:organisation)
        fail ArgumentError, "The Rack::Backbone.cdn method needs the Rack environment passed to it, or at the very least, an empty hash."
      end

      organisation =  options[:organisation] ||
                        env["rack.backbone.organisation"] ||
                        :media_temple

      script = case organisation
        when :cloudflare
          CDN::CLOUDFLARE
        when :jsdelivr
          CDN::JSDELIVR
        else
          CDN::CLOUDFLARE
      end

      http_path = env["rack.backbone.http_path"]

      "<script src='#{script}'></script>\n#{FALLBACK_TOP}#{http_path}#{FALLBACK_BOTTOM}"
    end



    # @param [#call] app
    # @param [Hash] options
    # @option options [String] :http_path If you wish the Backbone fallback route to be "/js/backbone-1.9.1.min.js" (or whichever version this is at) then do nothing, that's the default. If you want the path to be "/assets/javascripts/backbone-1.9.1.min.js" then pass in `:http_path => "/assets/javascripts".
    # @option options [Symbol] :organisation see {Rack::Backbone.cdn}
    # @example
    #   # The default:
    #   use Rack::Backbone
    #
    #   # With a different route to the fallback:
    #   use Rack::Backbone, :http_path => "/assets/js"
    #
    #   # With a default organisation:
    #   use Rack::Backbone, :organisation => :cloudflare
    def initialize( app, options={} )
      @app, @options  = app, DEFAULT_OPTIONS.merge(options)
      @http_path_to_backbone = ::File.join @options[:http_path], BACKBONE_FILE_NAME
      @http_path_to_source_map = ::File.join @options[:http_path], BACKBONE_SOURCE_MAP_UNVERSIONED
      @organisation = options.fetch :organisation, :media_temple
    end


    # @param [Hash] env Rack request environment hash.
    def call( env )
      dup._call env
    end


    # For thread safety
    # @param (see #call)
    def _call( env )
      request = Rack::Request.new(env.dup)
      env.merge! "rack.backbone.organisation" => @organisation
      env.merge! "rack.backbone.http_path" => @http_path_to_backbone
      if request.path_info == @http_path_to_backbone
        response = Rack::Response.new
        # for caching
        response.headers.merge! caching_headers( BACKBONE_FILE_NAME, BACKBONE_VERSION_DATE)

        # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
        if request.env['HTTP_IF_MODIFIED_SINCE']
          response.status = 304
        else
          response.status = 200
          response.write ::File.read( ::File.expand_path "../../../vendor/assets/javascripts/#{BACKBONE_FILE_NAME}", __FILE__)
        end
        response.finish
      elsif request.path_info == @http_path_to_source_map
        response = Rack::Response.new
        # No need for caching with the source map
        response.status = 200
        response.write ::File.read( ::File.expand_path "../../../vendor/assets/javascripts/#{BACKBONE_SOURCE_MAP}", __FILE__)
        response.finish
      else
        @app.call(env)
      end
    end # call

  end
end

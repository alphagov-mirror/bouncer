module Bouncer
  ##
  # Regex rules to try after mappings but just before we 404
  class FallbackRules
    def self.redirect(location)
      [301, { 'Location' => location }, []]
    end

    def self.gone(context, renderer)
      [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
    end

    def self.try(context, renderer)
      request = context.request
      if request.host == 'www.dfid.gov.uk' && request.path =~ %r{^/r4d/(.*)$}
        new_path = request.non_canonicalised_path.gsub(%r{^/r4d/}, "")
        redirect("http://r4d.dfid.gov.uk/#{new_path}")
      elsif request.host == 'www.dh.gov.uk' && request.path =~ %r{/dh_digitalassets/}
        gone(context, renderer)
      elsif request.host == 'www.direct.gov.uk' && request.path =~ %r{/(en/)?AdvancedSearch}i
        redirect('https://www.gov.uk/search')
      elsif request.host == 'campaigns.direct.gov.uk' && request.path =~ %r{/firekills}
        redirect('https://www.gov.uk/firekills')
      elsif request.host == 'www.number10.gov.uk' && request.path =~ %r{^/news/?([_0-9a-zA-Z-]+)?/([0-9]+)/([0-9]+)/(.*)-([0-9]+)$}
        redirect("http://www.number10.gov.uk/news/#{$4}")
      elsif request.host == 'cdn.hm-treasury.gov.uk' && request.path =~ %r{^/(.*)$}
        redirect("http://www.hm-treasury.gov.uk/#{$1}")
      elsif request.host == 'digital.cabinetoffice.gov.uk' && request.path =~ %r{^/(.*)$}
        redirect("https://gds.blog.gov.uk/#{$1}")
      end
    end
  end
end
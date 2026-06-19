source "https://rubygems.org"

# Core static site generator
gem "jekyll", "~> 4.3"

# HTML parsing used by the custom auto-hyperlink plugin (_plugins/autolink.rb).
# Nokogiri lets us link only real text nodes and safely skip code, headings
# and existing <a> tags.
gem "nokogiri", "~> 1.16"

# Plugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
  gem "jekyll-paginate", "~> 1.1"
end

# Windows / JRuby support for file watching
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
  gem "wdm", "~> 0.1.1"
end

# Lock http_parser.rb gem to v0.6.x on JRuby builds
gem "http_parser.rb", "~> 0.6.0", platforms: [:jruby]

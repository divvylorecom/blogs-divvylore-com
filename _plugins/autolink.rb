# ============================================================================
# _plugins/autolink.rb
# ----------------------------------------------------------------------------
# Automatically turns configured words / phrases into hyperlinks.
#
# Terms are defined in _data/autolinks.yml and global behaviour in _config.yml
# under the `autolink:` key.
#
# The plugin runs AFTER Markdown has been rendered to HTML (`:post_render`),
# walks only real text nodes, and never touches:
#   * existing links (<a>)
#   * code (<code>, <pre>, <kbd>, <samp>)
#   * headings (<h1>–<h6>)
#   * <script> / <style>
#
# Because it relies on a custom Ruby plugin, the site must be built with
# Bundler (see the GitHub Actions workflow in .github/workflows/), not the
# default GitHub Pages gem build.
# ============================================================================

require "nokogiri"
require "cgi"

module Jekyll
  module AutoLink
    # Elements whose text content must never be auto-linked.
    SKIP_ELEMENTS = %w[a code pre kbd samp script style h1 h2 h3 h4 h5 h6].freeze

    # Unicode "word" character class used for whole-word boundaries.
    WORD_CHAR = '[\p{L}\p{N}_]'.freeze

    class Linker
      def initialize(site)
        cfg = site.config["autolink"] || {}
        @enabled       = cfg.fetch("enabled", true)
        @default_limit = (cfg["limit_per_term"] || 1).to_i
        @new_tab       = cfg.fetch("new_tab", true)
        @css_class     = (cfg["css_class"] || "auto-link").to_s
        @entries       = build_entries(site.data["autolinks"])
        @regex         = build_regex(@entries)
      end

      def enabled?
        @enabled && @entries.any? && !@regex.nil?
      end

      # Public entry point: takes rendered HTML, returns HTML with auto-links.
      def process(html)
        return html if html.nil? || html.empty?

        fragment = Nokogiri::HTML.fragment(html)
        counts = Hash.new(0)
        walk(fragment, counts)
        fragment.to_html
      end

      private

      def build_entries(raw)
        return [] unless raw.is_a?(Array)

        raw.filter_map do |entry|
          next unless entry.is_a?(Hash)

          term = entry["term"].to_s.strip
          url  = entry["url"].to_s.strip
          next if term.empty? || url.empty?

          {
            term:           term,
            url:            url,
            title:          entry["title"],
            match:          (entry["match"] || "word").to_s,
            case_sensitive: entry["case_sensitive"] == true,
            limit:          entry.key?("limit") ? entry["limit"].to_i : @default_limit,
            key:            term.downcase,
          }
          # Longest terms first so phrases beat the single words inside them.
        end.sort_by { |e| -e[:term].length }
      end

      def build_regex(entries)
        return nil if entries.empty?

        alternation = entries.map { |e| term_pattern(e) }.join("|")
        Regexp.new("(#{alternation})", Regexp::IGNORECASE)
      end

      def term_pattern(entry)
        body = Regexp.escape(entry[:term])
        if entry[:match] == "phrase"
          body
        else
          "(?<!#{WORD_CHAR})#{body}(?!#{WORD_CHAR})"
        end
      end

      def lookup(matched)
        key = matched.downcase
        @entries.find { |e| e[:key] == key }
      end

      def walk(node, counts)
        node.children.to_a.each do |child|
          if child.text?
            replace_text(child, counts)
          elsif child.element? && !SKIP_ELEMENTS.include?(child.name.downcase)
            walk(child, counts)
          end
        end
      end

      def replace_text(text_node, counts)
        content = text_node.content
        return unless content&.match?(@regex)

        out = +""
        last = 0

        content.scan(@regex) do
          match   = Regexp.last_match
          matched = match[0]
          out << CGI.escapeHTML(content[last...match.begin(0)])

          entry = lookup(matched)
          if entry && allowed?(entry, matched, counts)
            counts[entry[:key]] += 1
            out << anchor(entry, matched)
          else
            out << CGI.escapeHTML(matched)
          end

          last = match.end(0)
        end

        out << CGI.escapeHTML(content[last..-1]) if last < content.length

        text_node.replace(Nokogiri::HTML.fragment(out))
      end

      def allowed?(entry, matched, counts)
        return false if entry[:case_sensitive] && matched != entry[:term]
        return true  if entry[:limit] <= 0

        counts[entry[:key]] < entry[:limit]
      end

      def anchor(entry, text)
        attrs = +%(href="#{CGI.escapeHTML(entry[:url])}" class="#{CGI.escapeHTML(@css_class)}")
        attrs << %( title="#{CGI.escapeHTML(entry[:title].to_s)}") if entry[:title]
        attrs << %( target="_blank" rel="noopener noreferrer") if @new_tab
        %(<a #{attrs}>#{CGI.escapeHTML(text)}</a>)
      end
    end

    # One Linker per site build, memoised by site object id.
    def self.linker_for(site)
      @linkers ||= {}
      @linkers[site.object_id] ||= Linker.new(site)
    end
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  linker = Jekyll::AutoLink.linker_for(post.site)
  next unless linker.enabled?

  post.output = linker.process(post.output)
end

# Clear the memoised linkers after each build so `serve`/watch picks up edits
# to _data/autolinks.yml without a restart.
Jekyll::Hooks.register :site, :post_write do |_site|
  Jekyll::AutoLink.instance_variable_set(:@linkers, {})
end

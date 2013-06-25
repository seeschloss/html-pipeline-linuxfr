# encoding: utf-8
module HTML
  class Pipeline

    class CustomLinksFilter < Filter

      LF_REGEXP = /\[\[\[([ '\.:\-\p{Word}]+)\]\]\]/
      WP_REGEXP = /\[\[([ '\.+:!\-\(\)\p{Word}]+)\]\]/

      LF_TITLE = "Lien du wiki interne LinuxFr.org"
      WP_TITLE = "Définition Wikipédia"

      # Don't look for links in text nodes that are children of these elements
      IGNORE_PARENTS = %w(pre code a).to_set

      def call
        doc.search('text()').each do |node|
          content = node.to_html
          next if !content.include?('[[')
          next if has_ancestor?(node, IGNORE_PARENTS)
          html = content
          html = process_internal_wiki_links html
          html = process_wikipedia_links html
          next if html == content
          node.replace(html)
        end
        doc
      end

      def process_internal_wiki_links(text)
        base_url = "//#{context[:host]}/wiki"
        text.gsub(LF_REGEXP, "<a href=\"#{base_url}/\1\" title=\"#{LF_TITLE}\">\\1</a>")
      end

      def process_wikipedia_links(text)
        text.gsub(WP_REGEXP) do
          word = $1
          escaped = word.gsub(/\(|\)|'/) {|x| "\\#{x}" }
          parts = word.split(":")
          parts.shift if %w(de en es eo wikt).include?(parts.first)
          "<a href=\"http://fr.wikipedia.org/wiki/#{escaped}\" title=\"#{WP_TITLE}\")>#{parts.join ':'}</a>"
        end
      end

    end

  end
end
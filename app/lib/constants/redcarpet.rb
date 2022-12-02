module Constants
  module Redcarpet
    CONFIG = {
      autolink: true,
      no_intra_emphasis: false, # disabled, not suitable for linguistic contents
      fenced_code_blocks: true,
      lax_html_blocks: true,
      lax_spacing: true,
      strikethrough: true,
      superscript: true, # enabled
      tables: true,
      footnotes: true
    }.freeze
  end
end

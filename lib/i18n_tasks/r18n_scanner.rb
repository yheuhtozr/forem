require "i18n/tasks/scanners/file_scanner"
class R18nScanner < I18n::Tasks::Scanners::FileScanner
  include I18n::Tasks::Scanners::OccurrenceFromPosition

  # @return [Array<[absolute key, Results::Occurrence]>]
  def scan_file(path)
    text = read_file(path)
    vars = text.scan(/(?<![\w.])(_[a-z]+)\s*=\s*t\.((?:(?!to_s)\w+\.)*(?!to_s)\w+)\b/).to_h
    known = (vars.keys << "t").map { |k| Regexp.quote k }.join "|"
    lookb = (vars.keys.map { |k| "#{Regexp.quote k} = " } << '[\w.]').join "|"
    text.scan(/(?<!#{lookb})(#{known})\.((?:(?!to_s)\w+\.)*(?!to_s)\w+)\b/).map do |match|
      occurrence = occurrence_from_position(
        path, text, Regexp.last_match.offset(0).first
      )
      prefix = match[0] == "t" ? "" : "#{vars[match[0]]}."
      ["#{prefix}#{match[1]}", occurrence]
    end
  end
end

I18n::Tasks.add_scanner "R18nScanner", only: %w[*.erb *.builder *.jbuilder]

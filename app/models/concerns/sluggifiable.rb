module Sluggifiable
  extend ActiveSupport::Concern

  def sluggify(string, locale = "")
    # lang code to babosa locale
    latin = {
      "bs" => :serbian,
      "da" => :danish,
      "de" => :german,
      "es" => :spanish,
      "hr" => :serbian,
      "mo" => :romanian,
      "nb" => :norwegian,
      "nn" => :norwegian,
      "no" => :norwegian,
      "ro" => :romanian,
      "sh" => :serbian,
      "sr" => :serbian,
      "sv" => :swedish
    }.detect { |k, _v| locale&.start_with? k }&.[](1) || :latin
    cyril = {
      "bg" => :bulgarian,
      "ru" => :russian,
      "sr" => :serbian
    }.detect { |k, _v| locale&.start_with? k }&.[](1) || :cyrillic
    # cyrillic comes first to suppress unwanted serbian cyrillic seeping in Babosa
    locales = [cyril, latin, :vietnamese, :greek, :hindi]
    string.to_s.sluggify(locales)
  end
end

class ConlangPortalSyncService
  ENDPOINT = "https://conlang-portal.herokuapp.com/api/cla/list?onlyApproved=1".freeze

  def initialize
    run ENDPOINT
  end

  private

  def run(path)
    # See https://github.com/Ziphil/ConlangPortal/blob/develop/document/api.md
    response = HTTParty.get path
    parsed = JSON.parse response.to_s
    return if parsed["entries"].blank?

    dialects = {}
    languages = {}
    parsed["entries"].each do |e|
      dit = e["codes"]["dialect"]
      lat = e["codes"]["language"]
      fat = e["codes"]["family"]
      ust = e["codes"]["user"]
      din = e["names"]["dialect"]
      lan = e["names"]["language"]
      _fan = e["names"]["family"]

      dialects["x-v3-#{f ust}#{f fat}#{f lat}-#{f dit}"] = "#{lan} #{din}" unless dit == "~"
      languages["x-v3-#{f ust}#{f fat}#{f lat}"] = lan unless lat == "~"
    end

    I18n.available_locales.each do |loc|
      File.open(Rails.root / "config" / "locales" / "cla_langs.#{loc}.yml", "w:utf-8") do |out|
        out.puts YAML.dump({ loc.to_s => { "languages" => dialects.merge(languages).sort.to_h } })
      end
    end
  end

  def f(code)
    code == "~" ? "0" : code
  end
end

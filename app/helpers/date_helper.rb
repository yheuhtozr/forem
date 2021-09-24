module DateHelper
  def local_date(datetime, show_year: true)
    datetime = Time.zone.parse(datetime) if datetime.is_a?(String)

    tag.time(
      datetime.strftime(show_year ? I18n.t("date.readable.full_year") : I18n.t("date.readable.with_year")),
      datetime: datetime.utc.iso8601,
      class: "date#{'-no-year' unless show_year}",
    )
  end
end

class PulseMetricsService
  include CalibreParsing

  def initialize(site, page)
    @site = site
    @page = page
    @command = "calibre site get-pulse-metrics --site=#{site} --page=#{page} --json"
  end

  def call
    Rails.cache.fetch("calibre:#{@site}:#{@page}:pulse-metrics", expires_in: 1.minute) do
      parse_data(raw_data_from_calibre)
      @data_hash[:page][:timeseries][:series].map do |serie|
        metric_hash = {}
        metric_hash[:metric_name] = serie[:metric][:name]
        serie[:sets].each do |set|
          metric_hash[set[:profile][:name]] = set[:values].last[:value]
        end
        metric_hash
      end
    end
  end
end

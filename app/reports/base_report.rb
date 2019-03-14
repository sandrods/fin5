class BaseReport

  def odt

    report = ODFReport::Report.new(template) do |r|
      populate(r)
    end

    report.generate
  end

  def pdf
    PDFConverter.convert(odt).force_encoding('UTF-8')
  end

  def populate(r)
    raise "Not Implemented"
  end

  private

  def template
    Rails.root.join('app', 'reports', 'odts', "#{odt_name}.odt")
  end

  def odt_name
    self.class.name.underscore.gsub('_report', '')
  end

end

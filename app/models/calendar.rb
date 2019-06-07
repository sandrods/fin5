class Calendar
  attr_accessor :date, :year, :days

  def initialize(date: nil, year: nil, days: nil)

    if date.present?
      @date = date.is_a?(String) ? Date.parse(date) : date
      if @date > range.last
        @date = @date.next_month.beginning_of_month
      end
      @start = range.begin
      @end = range.last

    elsif year.present?
      @date = Date.new year.to_i, 1, 1
      @start = @date.beginning_of_year
      @end = @date.end_of_year

    elsif days.present?
      @date = Date.today
      @start = @date - days
      @end = @date
      @days = days

    else
      @date = Date.today
      @start = range.begin
      @end = range.begin
    end

    @year = @date.year

  end

  def this_month?(day)
    day.month == @date.month
  end

  def future?
    @start.future?
  end

  def past?
    @end.past?
  end

  def month
    @date.strftime('%m/%Y')
  end

  def last_month
    @date.last_month.strftime('%m/%Y')
  end

  def next_month
    @date.next_month.strftime('%m/%Y')
  end

  def last_calendar
    Calendar.new(date: @date.last_month)
  end

  def next_calendar
    Calendar.new(date: @date.next_month)
  end

  def range
    ini = @date.beginning_of_month.last_month + 20
    fim = ini.next_month - 1
    ini..fim
  end

  def last_year
    @year - 1
  end

  def next_year
    @year + 1
  end

end

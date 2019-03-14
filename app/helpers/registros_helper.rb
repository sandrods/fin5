module RegistrosHelper

  def label_cd(cd)
    if cd.upcase == 'C'
      tag.span 'RECEITA', class: "badge badge-success"
    else
      tag.span 'DESPESA', class: "badge badge-danger"
    end
  end

  def combo_periodo
    [].tap do |p|
      p << ['Ultimos 7 dias',   7.days.ago.to_date]
      p << ['Ultimos 30 dias', 30.days.ago.to_date]
      p << ['Ultimos 60 dias', 60.days.ago.to_date]
      p << ['Ultimos 90 dias', 90.days.ago.to_date]
      p << ['Ultimos 6 meses',  6.months.ago.to_date]
      p << ['Ultimos 12 meses', 12.months.ago.to_date]
    end
  end

  def bool2cd(bool)
    if bool.to_s == '1'
      'C'
    else
      'D'
    end
  end
end

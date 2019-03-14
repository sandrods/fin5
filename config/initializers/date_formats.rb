# Inclua os seus formatos de data
# que podem ser utilizados com 'to_s'
#
# Ex.: @user.created_at.to_s(:my_format)

my_date_formats = {
  default: "%d/%m/%Y"
}

Date::DATE_FORMATS.merge!(my_date_formats)

my_date_time_formats = {
  default: "%d/%m/%Y %H:%M"
}

Time::DATE_FORMATS.merge!(my_date_time_formats)

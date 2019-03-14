class ApplicationRecord < ActiveRecord::Base
  include EnumPlus
  
  self.abstract_class = true
end

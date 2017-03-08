class Recipe < ApplicationRecord

  # belongs_to :user

  validates :name, :description, :category, :ingredient1, :quantity1, :instruction1, presence: true
  validates :name, :description, length: { minimum: 3 }
  # validates :ingredient2, :ingredient3, :ingredient4, :ingredient5, :ingredient6, :ingredient7, :ingredient8, :ingredient9, :ingredient10, :ingredient11, :ingredient12, :ingredient13, :ingredient14, :ingredient15, :ingredient16, :ingredient17, :ingredient18, :ingredient19, :ingredient20, :ingredient21, :ingredient22, allow_blank: true
  # validates :quantity2, :quantity3, :quantity4, :quantity5, :quantity6, :quantity7, :quantity8, :quantity9, :quantity10, :quantity11, :quantity12, :quantity13, :quantity14, :quantity15, :quantity16, :quantity17, :quantity18, :quantity19, :quantity20, :quantity21, :quantity22, allow_blank: true
  # validates :instruction2, :instruction3, :instruction4, :instruction5, :instruction6, :instruction7, :instruction8, :instruction9, :instruction10, :instruction11, :instruction12, :instruction13, :instruction14, :instruction15, :instruction16, :instruction17, :instruction18, :instruction19, :instruction20, allow_blank: true

end

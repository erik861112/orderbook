class ProductLine < ActiveRecord::Base
	has_many :products

	validates :name, presence: true, uniqueness: true
end

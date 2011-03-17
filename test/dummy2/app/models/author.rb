class Author < ActiveRecord::Base
  has_one :bio
  has_many :posts
end

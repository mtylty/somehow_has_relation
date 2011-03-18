class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :bio

  def recent?
    created_at >= 1.hour.ago
  end
end

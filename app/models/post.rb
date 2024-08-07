class Post < ApplicationRecord
    validates :title, presence: true
    validates :body, presence: true
    has_one_attached :avatar
end

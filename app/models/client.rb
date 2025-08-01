class Client < ApplicationRecord
    has_many :invoices
    has_many :comments, as: :commentable, dependent: :destroy
end

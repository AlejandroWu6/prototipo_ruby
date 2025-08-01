class User < ApplicationRecord
  has_secure_password

  has_many :invoices, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid email format" }
end
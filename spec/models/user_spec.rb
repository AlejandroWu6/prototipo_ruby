# spec/models/user_spec.rb
require 'rails_helper'


RSpec.describe User, type: :model do
  fixtures :users

  subject(:user) do
    described_class.new(
      email: "usuario@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  describe "validaciones" do
    it "es válido con un email y contraseña válidos" do
      expect(user).to be_valid
    end

    it "no es válido sin email" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "no es válido con un email duplicado" do
      described_class.create!(email: user.email, password: "otra123", password_confirmation: "otra123")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "no es válido con un email en formato incorrecto" do
      user.email = "email-no-valido"
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("invalid email format")
    end
  end

  describe "seguridad de contraseña" do
    it "requiere contraseña y confirmación coincidentes" do
      user.password_confirmation = "otra"
      expect(user).not_to be_valid
    end
  end

  describe "relaciones" do
    it "puede tener muchas facturas (invoices)" do
      expect(user.invoices).to eq([])
    end
  end

  describe "fixtures" do
    it "carga correctamente el fixture 'one'" do
      user_one = User.find_by(email: "user1@example.com")
      expect(user_one).not_to be_nil
      expect(user_one.email).to eq("user1@example.com")
    end

    it "carga correctamente el fixture 'two'" do
      user_two = User.find_by(email: "user2@example.com")
      expect(user_two).not_to be_nil
      expect(user_two.email).to eq("user2@example.com")
    end

    it "autentica correctamente el fixture 'one'" do
      user_one = User.find_by(email: "user1@example.com")
      expect(user_one.authenticate("password123")).to eq(user_one)
    end
  end
end

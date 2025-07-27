require "test_helper"

class PasswordMailerTest < ActionMailer::TestCase
  test "reset" do
    user = users(:one)

    mail = PasswordMailer.with(user: user).reset

    assert_equal [user.email], mail.to
    assert_equal "Reset", mail.subject 
    assert_match user.email, mail.body.encoded 
    assert_match /\/password\/reset\/edit\/[\w\-]+/, mail.body.encoded # comprobacion del token / enlace
  end
end

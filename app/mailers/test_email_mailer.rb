class TestEmailMailer < ApplicationMailer
  def test_email(to)
    subject = 'This is a testing email'

    send_mail(to: to, subject: subject)
  end
end

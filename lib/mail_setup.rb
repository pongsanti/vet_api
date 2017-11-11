require 'mail'
require 'dotenv/load'

Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp.gmail.com',
    port: 587,
    user_name: ENV['SMTP_EMAIL'],
    password: ENV['SMTP_PASS'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
end

def doctor_app_mail_content obj
"
Doctor name: #{obj[:name]}
Start at: #{obj[:start_at]}
End at: #{obj[:end_at]}
"
end

def send_app_mail obj
  mail = Mail.new do
    from    'admin@vet.com'
    to      ENV['MAIL_DESTINATION']
    subject "A doctor appointment created"
    body    doctor_app_mail_content(obj)
  end
  Thread.new do
    mail.deliver
  end
end
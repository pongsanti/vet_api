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
Originator: John Doe
Start at: #{obj[:start_at]}
End at: #{obj[:end_at]}
"
end

def vehicle_app_mail_content obj
  "
  Vehicle plate: #{obj[:plate]}
  Vehicle type: #{obj[:type]}
  Location: Sukhumvit Rd. (#{obj[:vehicle_id]})
  Originator: John Doe
  Start at: #{obj[:start_at]}
  End at: #{obj[:end_at]}
  "
end

def send_doctor_app_mail obj
  send_app_mail('A doctor appointment created', doctor_app_mail_content(obj))
end

def send_vehicle_app_mail obj
  send_app_mail('A vehicle appointment created', vehicle_app_mail_content(obj))
end

def send_app_mail(subject, content)
  mail = Mail.new do
    from    'admin@vet.com'
    to      ENV['MAIL_DESTINATION']
    subject subject
    body    content
  end
  Thread.new do
    mail.deliver
  end
end
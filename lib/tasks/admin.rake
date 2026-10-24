namespace :admin do
  desc "Создать аккаунт автора с интерактивным вводом пароля"
  task create: :environment do
    require "io/console"
    abort "Аккаунт автора уже существует." if AdminUser.exists?
    abort "Запустите задачу в интерактивном терминале." unless $stdin.tty?
    print "Почта: "
    email = $stdin.gets.to_s.strip
    print "Пароль (не меньше 12 символов): "
    password = $stdin.noecho(&:gets).to_s.chomp
    puts
    print "Повторите пароль: "
    confirmation = $stdin.noecho(&:gets).to_s.chomp
    puts
    admin = AdminUser.create!(email: email, password: password, password_confirmation: confirmation)
    puts "Аккаунт #{admin.email} создан. Вход: /admin/login"
  rescue ActiveRecord::RecordInvalid => error
    abort error.record.errors.full_messages.join("; ")
  end
end

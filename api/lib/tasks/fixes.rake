namespace :fixes do
  namespace :users do
    desc 'Creates random password to existing users (if empty)'

    task :passwords => :environment do
      passwordless_users = User.where(:password_digest => nil)
      passwordless_users.find_each do |user|
        user.send(:autogenerate_password)
        user.save
      end
    end
  end
end
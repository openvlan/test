require 'csv'

namespace :export do
  desc "Export institutions"
  task institutions: :environment do
    institutions = Institution.unscoped
    keys = [:id, :name, :legal_name, :uid_type, :uid, :type]
    puts "About to export #{institutions.count} institutions"

    CSV.open("./tmp/institutions.csv", 'w') do |csv|
      csv << keys
      institutions.find_each do |institution|
        print '.'
        csv << keys.map { |key| institution.send(key) }
      end
      puts ''
    end

    puts "Exported"
  end

  desc "Export profiles"
  task profiles: :environment do
    profiles = Profile.unscoped
    keys = [:id, :first_name, :first_name, :user_id, :extras]
    puts "About to export #{profiles.count} profiles"

    CSV.open("./tmp/profiles.csv", 'w') do |csv|
      csv << keys
      profiles.find_each do |profile|
        print '.'
        csv << keys.map { |key| profile.send(key) }
      end
      puts ''
    end

    puts "Exported"
  end

  desc "Export users"
  task users: :environment do
    users = User.unscoped
    keys = [:id, :username, :email, :password_digest, :token_expire_at, :login_count,
             :failed_login_count, :last_login_at, :last_login_ip, :active, :confirmed,
             :roles_mask, :settings, :discarded_at]
    puts "About to export #{users.count} users"

    CSV.open("./tmp/users.csv", 'w') do |csv|
      csv << keys
      users.find_each do |user|
        print '.'
        csv << keys.map { |key| user.send(key) }
      end
      puts ''
    end

    puts "Exported"
  end

  desc "Export addresses"
  task addresses: :environment do
    addresses = Address.unscoped
    keys = [:institution_id, :gps_coordinates, :street_1, :street_2, :zip_code, :city, :state,
            :country, :contact_name, :contact_cellphone, :contact_email, :telephone,
            :open_hours, :notes]
    puts "About to export #{addresses.count} addresses"

    CSV.open("./tmp/addresses.csv", 'w') do |csv|
      csv << keys
      addresses.find_each do |address|
        print '.'
        csv << keys.map { |key| address.send(key) }
      end
      puts ''
    end

    puts "Exported"
  end
end

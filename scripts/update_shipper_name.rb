# COMMIT=true rails runner scripts/update_shipper_name.rb

commit = ENV['COMMIT'] == 'true'

puts 'Will not update anything' unless commit
puts ''

Shipper.all.each do |shipper|
  user = shipper.user

  unless user
    puts "Skipped #{shipper.id}: does not have associated user"
    next
  end

  if shipper.first_name == user.first_name && shipper.last_name == user.last_name
    puts "Skipped #{shipper.id}: name is already up to date"
    next
  end

  puts "Updating #{shipper.id} (#{shipper.first_name}, #{shipper.last_name}) to (#{user.first_name}, #{user.last_name})"

  if commit
    shipper.update_attributes!(first_name: user.first_name, last_name: user.last_name)
    puts 'Updated!'
  end
end

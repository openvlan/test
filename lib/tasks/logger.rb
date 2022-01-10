module Tasks
  module Logger
    extend self

    def log_run(task_name)
      ensure_directory_precense
      today = Date.today
      log = ActiveSupport::Logger.new("lib/tasks/log/#{task_name}-#{today.year}-#{today.month}-#{today.day}.log")
      start_time = Time.now
      log.info "Task started at #{start_time}"

      yield(log)
      print "\n"

      end_time = Time.now
      duration = (start_time - end_time) / 1.minute
      log.info "Task finished at #{end_time} and last #{duration} minutes."
      log.close
    end

    private

    def ensure_directory_precense
      dir = File.dirname("#{Rails.root}/lib/tasks/log/.")
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

  end
end

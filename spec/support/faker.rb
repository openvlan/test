require 'faker'

dir = __dir__

I18n.load_path += Dir[File.join(dir, 'locales', '**', '*.yml')]
I18n.reload! if I18n.backend.initialized?

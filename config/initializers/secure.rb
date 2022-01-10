if Rails.env.production?
  # To prevent host header injection (http://carlos.bueno.org/2008/06/host-header-injection.html)
  Rails.application.config.action_controller.default_url_options = { host: Rails.application.secrets.hostname }
  # config.action_controller.asset_host = ""
end

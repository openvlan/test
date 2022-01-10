REDIS_DB   = Rails.application.secrets.redis_db
REDIS_HOST = Rails.application.secrets.redis_host
REDIS_PORT = Rails.application.secrets.redis_port
$redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
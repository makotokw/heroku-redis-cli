require 'uri'
class Heroku::Command::Redis < Heroku::Command::Base

  # redis:cli
  #
  #  Open a redis-cli shell to the database
  #
  # --db REDIS_URL      # specify a key of ENV to connect redis database
  def cli(*queries)
    db_env_key = options[:db] || 'REDIS_URL'
    config_vars = api.get_config_vars(app).body

    redis_url = config_vars[db_env_key] || config_vars['REDISTOGO_URL'] || config_vars['REDISCLOUD_URL']
    return puts "No such redis (#{db_env_key}), try setting --db REDIS_URL." unless redis_url

    uri = URI.parse(redis_url)

    cmd = ["redis-cli"]
    cmd << "-a" << uri.password if uri.password
    cmd << "-h" << uri.host if uri.host
    cmd << "-p" << uri.port.to_s if uri.port
    cmd << "-n" << uri.path.gsub("/", "").to_i.to_s

    # queries are set by monitor and info, and args are remaining command line arguments
    # passed to heroku redis.
    exec *(cmd + args + queries)
  end

  # redis:info
  #
  #  Get INFO for the redis database
  #
  # --db REDIS_URL      # specify a key of ENV to connect redis database
  def info; cli 'info'; end

  # redis:monitor
  #
  #  MONITOR the redis database
  #
  # --db REDIS_URL      # specify a key of ENV to connect redis database
  def monitor; cli 'monitor'; end
end

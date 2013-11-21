require 'uri'
class Heroku::Command::Redis < Heroku::Command::BaseWithApp

  def cli(*queries)
    db_env_key = extract_option("--db") || 'REDIS_URL'
    config_vars = api.get_config_vars(app).body

    redis_url = config_vars[db_env_key]
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

  def monitor; cli 'monitor'; end
  def info; cli 'info'; end
end

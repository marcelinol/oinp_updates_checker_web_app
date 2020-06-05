require_relative "../aws_initializer"
require "sequel"

class UserSubscriber
  USERS_LOCAL_PATH = "#{__dir__}/data/users.txt"
  BUCKET = "oinp-updates-checker"
  private_constant :BUCKET

  def initialize(email)
    validate_email(email)
    @email = email
  end

  def subscribe!
    if users.include?(@email)
      raise StandardError, "User #{@email} is already registered."
    end

    if users.size >= 10
      raise StandardError, "Limit of registered users reached. Sorry for the inconvenience."
    end

    db_client[:users].insert(
      email: @email,
      created_at: Time.now.getutc,
      active: true
    )
  end

  private

  # TODO: create DB client class
  def db_client
    @_db_client ||= Sequel.connect(
      adapter: :postgres,
      user: ENV["RDS_USERNAME"],
      password: ENV["RDS_PASSWORD"],
      host: ENV["RDS_HOST"],
      port: ENV["RDS_PORT"],
      database: "postgres",
      max_connections: 10,
    )
  end

  def users
    @users ||= db_client[:users].select(:email).map(:email)
  end

  def validate_email(email)
    unless email.match(URI::MailTo::EMAIL_REGEXP)
      raise ArgumentError, "Invalid email. #{email} is not an email"
    end
  end
end
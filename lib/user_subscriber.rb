require_relative "../aws_initializer"

class UserSubscriber
  USERS_LOCAL_PATH = "#{__dir__}/data/users.txt"
  BUCKET = "oinp-updates-checker"
  private_constant :BUCKET

  def initialize(email)
    # TODO: Validate email
    @email = email
    @bucket = Aws::S3::Resource.new.bucket(BUCKET)
  end

  def subscribe!
    if users.include?(@email)
      raise StandardError, "User #{@email} is already registered."
    end

    File.open(USERS_LOCAL_PATH, "w:UTF-8") do |file|
      text = (users << @email).join(",")
      file.write(text)
    end

    object = @bucket.object("users.txt")
    object.upload_file(USERS_LOCAL_PATH)
  end

  private

  def users
    @users ||= begin
      object = @bucket.object("users.txt")
      object.get(response_target: USERS_LOCAL_PATH)

      users = File.open(USERS_LOCAL_PATH, "r:UTF-8", &:read)
      users.split(",")
    end
  end
end
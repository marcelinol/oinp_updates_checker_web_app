require "aws-sdk-s3"
require "dotenv"
Dotenv.load("#{__dir__}/.env")

Aws.config.update(
  region: ENV["AWS_REGION"],
  credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
)
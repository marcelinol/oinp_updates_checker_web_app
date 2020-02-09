require "aws-sdk-s3"
require "dotenv"
Dotenv.load("#{__dir__}/.env")

region = ENV["AWS_REGION"] || "us-east-1"
access_key = ENV["AWS_ACCESS_KEY_ID"] || "none"
secret_key = ENV["AWS_SECRET_ACCESS_KEY"] || "secret"

Aws.config.update(
  region: region,
  credentials: Aws::Credentials.new(access_key, secret_key)
)
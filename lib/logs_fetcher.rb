require_relative "../aws_initializer"

class LogsFetcher
  # TODO: Solve duplication of BUCKET constant (check user_subscriber.rb)
  BUCKET = "oinp-updates-checker"
  LOGS_LOCAL_PATH = "#{__dir__}/data/logs.txt"
  ONE_CRAWLING_PATTERN = /(^\[.*\n\[.*\n)/
  private_constant :BUCKET

  def initialize
    @bucket = Aws::S3::Resource.new.bucket(BUCKET)
  end

  def logs
    fetch
    all_logs = File.open(LOGS_LOCAL_PATH, "r:UTF-8", &:read)
    groups = all_logs.scan(ONE_CRAWLING_PATTERN)
    groups[-10, 10].flatten.map { |log| log.gsub("\n", "<br />") }
  end

  # TODO: Only download file if the last download is older  than 2 hours
  def fetch
    object = @bucket.object("run_logs.txt")
    object.get(response_target: LOGS_LOCAL_PATH)
  end
end
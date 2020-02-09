require_relative "../../lib/logs_fetcher"

RSpec.describe LogsFetcher do
  let(:fake_aws_object) { spy("object") }
  let(:logs_fetcher) { LogsFetcher.new }
  let(:aws_bucket) { logs_fetcher.instance_variable_get(:@bucket) }

  before do
    allow(aws_bucket)
      .to receive(:object)
        .with("run_logs.txt")
        .and_return(fake_aws_object)

    stub_request(:get, "https://oinp-updates-checker.s3.amazonaws.com/run_logs.txt")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:put, "https://oinp-updates-checker.s3.amazonaws.com/run_logs.txt")
      .to_return(status: 200, body: "", headers: {})
  end

  describe "#fetch" do
    it "reads logs from aws" do
      logs_fetcher.fetch

      expect(fake_aws_object)
        .to have_received(:get)
          .with(response_target: LogsFetcher::LOGS_LOCAL_PATH)
    end
  end

  describe "#logs" do
    let(:logs_for_last_ten_run) {
      [
        "[2020-02-07 07:00:04 -0500] Crawling started.<br />[2020-02-07 07:00:13 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-07 09:00:04 -0500] Crawling started.<br />[2020-02-07 09:00:13 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-07 11:00:05 -0500] Crawling started.<br />[2020-02-07 11:00:13 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-07 13:00:04 -0500] Crawling started.<br />[2020-02-07 13:00:14 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-07 15:00:04 -0500] Crawling started.<br />[2020-02-07 15:00:13 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-07 17:00:04 -0500] Crawling started.<br />[2020-02-07 17:00:13 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-08 03:00:05 -0500] Crawling started.<br />[2020-02-08 03:00:16 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-08 11:00:04 -0500] Crawling started.<br />[2020-02-08 11:00:14 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-09 03:00:05 -0500] Crawling started.<br />[2020-02-09 03:00:16 -0500] Finished. The OINP has no new updates.<br />",
        "[2020-02-09 11:00:05 -0500] Crawling started.<br />[2020-02-09 11:00:14 -0500] Finished. The OINP has no new updates.<br />"
      ]
    }

    it "returns the logs for the last 10 times that the OINP page crawler ran" do
      allow(File)
        .to receive(:open)
        .with(LogsFetcher::LOGS_LOCAL_PATH, "r:UTF-8")
        .and_return(fixture("logs.txt"))

      expect(logs_fetcher.logs).to eq(logs_for_last_ten_run)
    end
  end
end
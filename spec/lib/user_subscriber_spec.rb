require_relative "../../lib/user_subscriber"

RSpec.describe UserSubscriber do
  describe "validations" do
    it "validates if given email is  an email" do
    end
  end

  it "raises error if user" do
    user_email = "xunda@example.com"
    user_subscriber = UserSubscriber.new(user_email)

    allow(user_subscriber).to receive(:users).and_return([user_email])

    expect { user_subscriber.subscribe! }
      .to raise_error(StandardError, "User #{user_email} is already registered.")
  end

  describe "#subscribe!" do
    let(:fake_aws_object) { spy("object") }
    let(:user_subscriber) { UserSubscriber.new("xunda@example.com") }
    let(:aws_bucket) { user_subscriber.instance_variable_get(:@bucket) }

    before do
      allow(aws_bucket)
        .to receive(:object)
        .with("users.txt")
        .and_return(fake_aws_object)

      stub_request(:get, "https://oinp-updates-checker.s3.amazonaws.com/users.txt")
        .to_return(status: 200, body: "", headers: {})
      stub_request(:put, "https://oinp-updates-checker.s3.amazonaws.com/users.txt")
        .to_return(status: 200, body: "", headers: {})
    end

    after do
      File.open(UserSubscriber::USERS_LOCAL_PATH, "w:UTF-8") do |file|
        file.write("")
      end
    end

    it "writes new user to local file" do
      UserSubscriber.new("new@example.com").subscribe!

      users = File.open(UserSubscriber::USERS_LOCAL_PATH, "r:UTF-8", &:read)

      expect(users).to match("new@example.com")
    end

    it "uploads users file in aws"  do
      user_subscriber.subscribe!

      expect(fake_aws_object)
        .to have_received(:upload_file)
          .with(UserSubscriber::USERS_LOCAL_PATH)
    end

    it "reads existing users from file in aws" do
      user_subscriber.subscribe!

      expect(fake_aws_object)
        .to have_received(:get)
          .with(response_target: UserSubscriber::USERS_LOCAL_PATH)
    end
  end
end
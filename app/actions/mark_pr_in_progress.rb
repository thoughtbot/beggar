class MarkPrInProgress
  EXCLUDED_USERS = ['houndci']

  def initialize(parser, pull_request)
    @parser = parser
    @pull_request = pull_request
  end

  def self.matches(parser, _pull_request)
    comments?(parser.event_type) &&
      EXCLUDED_USERS.exclude?(parser.comment_user_login)
  end

  def self.comments?(event_type)
    ["pull_request_review_comment", "issue_comment"].include?(event_type)
  end
  private_class_method :comments?

  def call
    pull_request.update(status: "in progress")
  end

  protected

  attr_reader :parser, :pull_request
end

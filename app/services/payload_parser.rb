class PayloadParser
  def initialize(payload, headers)
    @payload = payload
    @headers = headers
  end

  def action
    payload["action"]
  end

  def event_type
    headers["X-Github-Event"]
  end

  def comment
    payload["comment"] || {}
  end

  def github_issue_id
    pull_request_or_issue_params["id"]
  end

  def params
    {
      github_issue_id: github_issue_id,
      github_url: github_url,
      repo_name: repo_name,
      repo_github_url: repo_github_url,
      title: title,
      user_name: user_name,
      user_github_url: user_github_url,
    }
  end

  def comment_user
    comment["user"]["login"]
  end

  protected

  attr_reader :headers

  private

  def pull_request_or_issue_params
    payload["pull_request"] || payload["issue"]
  end

  def github_url
    payload["pull_request"]["html_url"]
  end

  def repo_name
    payload["pull_request"]["head"]["repo"]["full_name"]
  end

  def repo_github_url
    payload["pull_request"]["head"]["repo"]["html_url"]
  end

  def title
    payload["pull_request"]["title"]
  end

  def user_name
    payload["pull_request"]["head"]["user"]["login"]
  end

  def user_github_url
    payload["pull_request"]["head"]["user"]["html_url"]
  end

  def payload
    @_payload ||= parse_payload
  end

  def parse_payload
    JSON.parse(@payload).tap do |parsed_payload|
      Rails.logger.ap(parsed_payload, :info)
    end
  end
end

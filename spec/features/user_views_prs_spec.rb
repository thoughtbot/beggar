require "rails_helper"

feature "User views PRs" do
  scenario "Sees all open Pull Requests" do
    create(:pull_request, title: "Implement Stuff")
    create(:pull_request, title: "Design Stuff")

    visit root_path

    expect(page).to have_content("Implement Stuff")
    expect(page).to have_content("Design Stuff")
  end

  scenario "Sees link to PR on Github" do
    create(:pull_request, title: "Implement Stuff", github_url: "https://github.com/thoughtbot/pr-tool/pulls/1")

    visit root_path

    expect(page).to have_link("Implement Stuff", href: "https://github.com/thoughtbot/pr-tool/pulls/1")
  end

  scenario "Sees link to repo on Github" do
    create(:pull_request, repo_name: "thoughtbot/pr-tool", repo_github_url: "https://github.com/thoughtbot/pr-tool")

    visit root_path

    expect(page).to have_link("thoughtbot/pr-tool", href: "https://github.com/thoughtbot/pr-tool")
  end

  scenario "Sees metadata" do
    create(
      :pull_request,
       created_at: 1.hour.ago,
       user_name: "JoelQ",
       user_github_url: "https://github.com/joelq",
       github_url: "https://github.com/org/repo/pulls/123",
       avatar_url: "http://myavatar.com",
    )

    visit root_path

    expect(page).to have_content("#123 opened about 1 hour ago by JoelQ")
    expect(page).to have_link("JoelQ", href: "https://github.com/joelq")
    expect(page).to have_avatar("http://myavatar.com")
  end

  scenario "Does not see completed PRs" do
    create(:pull_request, title: "Implement Stuff", status: "needs review")
    create(:pull_request, title: "Review Stuff", status: "in progress")
    create(:pull_request, title: "Design Stuff", status: "completed")

    visit root_path

    expect(page).to have_content("Implement Stuff")
    expect(page).to have_content("Review Stuff")
    expect(page).not_to have_content("Design Stuff")
  end

  scenario "Sees tags with active pull requests" do
    ember = create(:tag, name: "ember")
    rails = create(:tag, name: "rails")
    create(:pull_request, title: "An Ember PR", tags: [ember], status: "completed")
    create(:pull_request, title: "A Rails PR", tags: [rails], status: "needs review")

    visit root_path

    within(".tags") do
      expect(page).to have_content("Rails")
      expect(page).not_to have_content("Ember")
    end
  end

  scenario "Can filter by tags" do
    create_pull_requests_with_tags

    visit root_path
    within(".tags") do
      click_on "Ember"
    end

    expect(page).to have_content("An Ember PR")
    expect(page).not_to have_content("A Rails PR")
    expect(page).to have_content("A PR that should probably have been split up")
  end

  scenario "Can filter by multiple tags" do
    create_pull_requests_with_tags

    visit root_path(tags: "ember")
    within(".tags") do
      click_on "Rails"
    end

    expect(page).to have_content("An Ember PR")
    expect(page).to have_content("A Rails PR")
    expect(page).to have_content("A PR that should probably have been split up")
  end

  scenario "Can remove a tag from filtered tags" do
    create_pull_requests_with_tags

    visit root_path(tags: "ember,rails")
    within(".tags") do
      click_on "Ember"
    end

    expect(page).not_to have_content("An Ember PR")
    expect(page).to have_content("A Rails PR")
    expect(page).to have_content("A PR that should probably have been split up")
  end

  private

  def create_pull_requests_with_tags
    ember = create(:tag, name: "ember")
    rails = create(:tag, name: "rails")
    create(:pull_request, title: "An Ember PR", tags: [ember])
    create(:pull_request, title: "A Rails PR", tags: [rails])
    create(:pull_request, title: "A PR that should probably have been split up", tags: [rails, ember])
  end

  def have_avatar(url)
    have_css("img[src='#{url}']")
  end
end

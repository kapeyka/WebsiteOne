Then(/^I should( not)? receive a "([^"]*)" email$/) do |negate, subject|
  check_email(nil, negate, subject)
end

Then(/^the user should( not)? receive a "([^"]*)" email$/) do |negate, subject|
  check_email('random@morerandom.com', negate, subject)
end

And /^"(.*?)" should( not)? receive a "(.*?)" email(?: containing "(.*)")?$/ do |user_email, negate, subject, body|
  check_email(user_email, negate, subject, body)
end

def check_email(email, negate, subject, body = nil)

  emails = ActionMailer::Base.deliveries

  matches = emails.map do |mail|
    # TODO use https://github.com/samg/diffy
    # puts subject, body, email
    # puts mail.subject, mail.body, mail.to
    [mail.subject == subject,   # 'hello' - 'hello' ==> ''  # 'hellow' - hello ==> 'w'
    body_match = body.nil? ? true : mail.body == body,
    email_match = mail.to.include?(email)]
  end
  # matches might =? [[false, false, true],[true, true, true]]

  if negate
    expect(matches).not_to include [true, true, true]
  else
    expect(matches).to include [true, true, true]
  end

  # expect(emails).to include_email_with_subject(subject)
#  it { is_expected.to include(be_odd.and be < 10) }
  # unless negate

  #   expect(ActionMailer::Base.deliveries[0].subject).to include(subject)
  #   expect(ActionMailer::Base.deliveries[0].body).to include(body) unless body.nil?
  #   expect(ActionMailer::Base.deliveries[0].to).to include(email) unless email.nil?
  # else
  #   expect(ActionMailer::Base.deliveries.size).to eq 0
  # end
end

And /^I should not receive an email$/ do
  expect(ActionMailer::Base.deliveries.size).to eq 0
end

And /^the email queue is clear$/ do
  ActionMailer::Base.deliveries.clear
end

When(/^replies to that email should go to "([^"]*)"$/) do |email|
  @email = ActionMailer::Base.deliveries.last
  expect(@email.reply_to).to include email
end

Given(/^I click on the retrieve password link in the last email$/) do
  password_reset_link = ActionMailer::Base.deliveries.last.body.match(
      /<a href=\"(.+)\">Change my password<\/a>/
  )[1]

  visit password_reset_link
end


require 'spec_helper'

describe 'Login' do

  let(:oauth_callback)     { 'http://www.example.com/dropbox/callback' }
  let(:oauth_token)        { 'oauth_token' }
  let(:oauth_token_secret) { 'oauth_token_secret' }
  let(:user_name)          { 'Test User' }

  let(:oauth_response) { { body: "oauth_token_secret=#{oauth_token_secret}&oauth_token=#{oauth_token}" } }
  let(:info_response)  { { body: %Q({"display_name": "#{user_name}"}) } }
  let(:authorize_url)  { "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{oauth_token}&oauth_callback=#{oauth_callback}" }

  before do
    stub_request(:get, "https://api.dropbox.com/1/oauth/request_token").to_return oauth_response
    stub_request(:get, "https://api.dropbox.com/1/oauth/access_token").to_return oauth_response
    stub_request(:get, "https://api.dropbox.com/1/account/info").to_return info_response
  end

  context 'when dropbox is unavailable' do
    before { stub_request(:any, /.*.dropbox.com/).to_timeout }

    it "should display an error" do
      login_and_expect_error
    end
  end

  context 'when dropbox is broken' do
    before { stub_request(:any, /.*.dropbox.com/).to_return status: 500 }

    it "should display an error" do
      login_and_expect_error
    end
  end

  context 'when the visitor is not logged in' do
    it "should redirect them to dropbox" do
      login
      expect(response).to redirect_to authorize_url
    end
  end

  context 'when the visitor is already logged in' do
    before { login_and_authorize }

    it 'should not reauthenticated' do
      login
      expect(a_request :get, "https://api.dropbox.com/1/oauth/request_token").to have_been_made.once
      expect(a_request :get, "https://api.dropbox.com/1/oauth/access_token").to have_been_made.once
    end
  end

  context 'when a new visitor authorises the app' do
    it 'should log them in' do
      login_and_authorize
      expect(response.body).to include "Welcome, #{user_name}"
    end
  end

  context 'when the visitor denies the app' do
    before { stub_request(:get, "https://api.dropbox.com/1/oauth/access_token").to_return status: 401 }

    it 'should render a polite failure' do
      login
      get_via_redirect "/dropbox/callback?not_approved=true"
      expect(CGI.unescapeHTML response.body).to include "Sorry, we couldn't connect to your Dropbox account."
    end
  end

  context 'when a returning user authorises the app' do
    pending
  end

  def login
    get '/dropbox/login'
  end

  def login_and_expect_error
    login
    follow_redirect!
    expect(CGI.unescapeHTML response.body).to include "Sorry, we can't connect to Dropbox right now"
  end

  def login_and_authorize
    login
    get_via_redirect "/dropbox/callback?uid=1234&oauth_token=#{oauth_token}"
  end

end

require 'spec_helper'

describe 'Login' do

  def login
    get '/login'
  end

  let(:oauth_callback)     { 'http://www.example.com/dropbox/callback' }
  let(:oauth_token)        { 'oauth_token' }
  let(:oauth_token_secret) { 'oauth_token_secret' }
  let(:uid)                { '1234' }

  context 'when dropbox is unavailable' do
    before { stub_request(:any, /.*.dropbox.com/).to_timeout }
    before { login }

    it "should display an error" do
      expect(response.body).to include "Unfortunately, we can't connect to Dropbox right now"
    end
  end

  context 'when dropbox is broken' do
    before { stub_request(:any, /.*.dropbox.com/).to_return status: 500 }
    before { login }

    it "should display an error" do
      expect(response.body).to include "Unfortunately, we can't connect to Dropbox right now"
    end
  end


  context 'when the visitor is not logged in' do
    before do
      stub_response = { body: "oauth_token_secret=#{oauth_token_secret}&oauth_token=#{oauth_token}" }
      stub_request(:get, "https://api.dropbox.com/1/oauth/request_token").to_return stub_response
    end
    before { login }

    it "should redirect them to dropbox" do
      url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{oauth_token}&oauth_callback=#{oauth_callback}"
      expect(response).to redirect_to url
    end
  end

  context 'when the visitor is already logged in'

  context 'when a new visitor authorises the app' do
    before do
      stub_response = { body: "oauth_token_secret=#{oauth_token_secret}&oauth_token=#{oauth_token}" }
      stub_request(:get, "https://api.dropbox.com/1/oauth/request_token").to_return stub_response
      stub_request(:get, "https://api.dropbox.com/1/oauth/access_token").to_return stub_response
      info_response = { body: %Q[{"uid": #{uid}}] }
      stub_request(:get, "https://api.dropbox.com/1/account/info").to_return info_response
    end
    before { login }
    before { get "/dropbox/callback?uid=#{uid}&oauth_token=#{oauth_token}"; follow_redirect! }

    it 'should render some info' do
      expect(response.body).to include "uid: #{uid}"
    end
  end
  context 'when a returning user authorises the app'
  context 'when the visitor denies the app'

end

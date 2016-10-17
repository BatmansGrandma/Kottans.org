require 'spec_helper'

describe Message do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :each do
    Message.all.destroy
  end

  describe "#create", :type => :request do
    it "creates a message via POST request" do
      post "/create", {msg: 'Sample message', destroy_option: 1}
      expect(Message.all.count).to eq(1)
    end
  end

  describe "#show" do
    it "creates a message via POST request and tryies to get it by its uid" do
      post "/create", {msg: 'Sample message', destroy_option: 1}
      expect(Message.all.count).to eq(1)
      uid = Message.last.uid
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('textarea', text: 'Sample message')
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('textarea', text: 'Sample message')
      Timecop.travel(Time.now+3605)
      get "/show/#{uid}"
      Timecop.travel(Time.now-3605)
      expect(last_response.body).to have_tag('h1', text: 'Sorry, your message was not found...')
    end
  end

  describe "#show" do
    it "creates and gets message which could be shown only once" do
      post "/create", {msg: 'Sample message', destroy_option: 0}
      expect(Message.all.count).to eq(1)
      uid = Message.last.uid
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('textarea', text: 'Sample message')
      expect(Message.all.count).to eq(0)
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('h1', text: 'Sorry, your message was not found...')
    end
  end

  describe "#show" do
    it "creates and checks message with no text" do
      post "/create", {msg: '', destroy_option: 0}
      expect(Message.all.count).to eq(1)
      uid = Message.last.uid
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('textarea', text: ' ')
      expect(Message.all.count).to eq(0)
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('h1', text: 'Sorry, your message was not found...')
    end
  end

  describe "#show" do
    it "creates and checks message with no text" do
      post "/create", {msg: '', destroy_option: 1}
      expect(Message.all.count).to eq(1)
      uid = Message.last.uid
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('textarea', text: ' ')
      get "/show/#{uid}"
      expect(last_response.body).to have_tag('textarea', text: ' ')
      Timecop.travel(Time.now+3605)
      get "/show/#{uid}"
      Timecop.travel(Time.now-3605)
      expect(last_response.body).to have_tag('h1', text: 'Sorry, your message was not found...')
    end
  end

end

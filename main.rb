require 'sinatra'
require 'securerandom'
require 'data_mapper'
require 'active_support/all'
require 'rspec'
require 'aes'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Message
  include DataMapper::Resource
  property :id,             Serial
  property :uid,            String
  property :message,        Text, :required => true
  property :destroy_option, Integer, :required => true
  property :created_at,     DateTime
end
DataMapper.finalize
DataMapper.auto_upgrade!

# TODO: Move this variable to the environment variables
CRYPTPASS = 'passwordpasswordpasswordpassword'

get '/' do
  erb :index
end

post '/create' do
  uid = SecureRandom.hex(6)
  message = (params['msg'].empty?) ? " " : params['msg']
  destroy_option = params['destroy_option']

  msg = Message.create(uid: uid, message: AES.encrypt(message, CRYPTPASS), destroy_option: destroy_option)
  @response_url = "#{request.base_url}/show/#{msg.uid}"

  erb :create
end

get '/show/:uid' do
  msg = Message.first uid: params['uid']
  if msg
    @result = AES.decrypt(msg.message, CRYPTPASS)
    @result.force_encoding("UTF-8")
    if msg.destroy_option == 0
      msg.destroy
    elsif msg.destroy_option == 1
      if msg.created_at + 1.hour < Time.now.to_datetime
        msg.destroy
        @result = nil
      end
    end
  else
    @result = nil
  end

  @result

  erb :show
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Message
  include DataMapper::Resource

  property :id, Serial
  property :title, Text, :required => true
  property :content, Text, :required => true
  property :episode, Integer, :required => false
  property :dinama_nekh, Integer, :default => 0
  property :published, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :content, Text, :required => true
  property :published, Boolean, :default => false
  property :created_at, DateTime

  belongs_to :user

end

class User
  include DataMapper::Resource

  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :email,      String
  property :provider,   String
  property :created_at, DateTime

  has n, :messages
  has n, :comments
end

class FacebookOauth
  include DataMapper::Resource

  property :id,   Serial
  property :access_token,  String
  property :user_id,  Integer

end
DataMapper.finalize.auto_upgrade!

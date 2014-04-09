require 'rubygems'
require 'fileutils'
require 'tempfile'
require 'sequel'
require 'colored'

class Kpt
  def self.db
    @db ||= Sequel.connect("sqlite://#{db_file}")
  end

  def self.db_file
    ENV['KPT_DB'] || File.join(ENV['HOME'], '.kpt', 'kpt.sqlite')
  end

  def self.create_db
    db.create_table :entries do
      primary_key :id
      Integer :tag_id
      String :body
      Integer :utc
    end
  end

  def self.setup
    unless File.exists?(db_file)
      FileUtils.mkpath File.dirname(db_file)
      Sequel.sqlite db_file
      create_db
    end
  end

  def initialize
    self.class.setup
    @db = self.class.db
  end

  def write(tag, body)
    entries.insert tag_id: tag_id(tag), body: body, utc: Time.now.to_i
  end

  def read(from = nil, to = nil, tag = nil)
    @entries = @db[:entries]
    if from
      @entries = @entries.where('utc >= ?', from.to_i)
    end
    if to
      @entries = @entries.where('utc <= ?', to.to_i)
    end
    if tag
      @entries = @entries.where(tag_id: tag_id(tag))
    end
  end

  def get(num = nil)
    if num
      @entries.limit num
    else
      @entries.all
    end
  end

  def entries
    @entries ||= @db[:entries]
  end

  def tag_id(tag)
    tags.index tag
  end

  def tags
    [:keep, :problem, :try]
  end

  
end

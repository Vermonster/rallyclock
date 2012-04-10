class Entry < Sequel::Model
  extend Forwardable

  many_to_one :user
  many_to_one :project

  delegate [:client, :group] => :project 

  #set_allowed_columns :time, :note, :user_id, :project_id

  def rel_path
    "entries/#{id}"
  end

  def validate
    super
    validates_presence :time
    validates_presence :note
    validates_presence :user_id
  end
end

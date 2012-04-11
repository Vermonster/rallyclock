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
    validates_presence [:time, :note, :user_id, :project_id]
  end
end

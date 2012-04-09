class Entry < Sequel::Model
  many_to_one :user

  set_allowed_columns :time, :note, :user_id

  def validate
    super
    validates_presence :time, :note, :user_id
  end
end

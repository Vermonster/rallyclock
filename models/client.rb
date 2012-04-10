class Client < Sequel::Model
  one_to_many :projects
  many_to_one :group

  def validate
    super
    validates_presence [:name, :account]
    validates_unique [:group_id, :account, :name]
    validates_format /^\w+$/, :account
  end
end

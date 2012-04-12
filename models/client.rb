class Client < Sequel::Model
  one_to_many :projects
  many_to_many :entries, :join_table => :projects
  many_to_one :group

  add_association_dependencies :projects => :destroy

  def rel_path
    "clients/#{account}"
  end

  def validate
    super
    validates_presence [:name, :account, :group_id]
    validates_unique [:group_id, :account, :name]
    validates_format /^\w+$/, :account
  end
end

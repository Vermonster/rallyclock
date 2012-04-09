class Group < Sequel::Model
  many_to_one :owner, :class => :User
  one_to_many :memberships
  many_to_many :users, :join_table => :memberships

  add_association_dependencies :memberships => :destroy

  def validate
    super
    validates_presence :name
    validates_unique [:name, :owner_id]
  end
end


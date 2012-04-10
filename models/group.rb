class Group < Sequel::Model
  many_to_one :owner, :class => :User
  one_to_many :memberships
  one_to_many :clients
  many_to_many :users, :join_table => :memberships

  add_association_dependencies :memberships => :destroy

  def validate
    super
    validates_presence :name
    validates_unique [:name, :owner_id]
  end

  def admins
    [owner] + memberships_dataset.filter(:admin).map(&:user)
  end

  def admin?(user)
    admins.include?(user) || owner?(user)
  end

  def owner?(user)
    owner == user
  end

  def add_admin(user)
    Membership.create(group_id: id, user_id: user.id, admin: true)
  end

  def add_member(user)
    Membership.create(group_id: id, user_id: user.id, admin: false)
  end

  def remove_member(user)
    memberships.first(user_id: user.id).destroy
  end
end


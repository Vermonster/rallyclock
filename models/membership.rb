class Membership < Sequel::Model
  one_to_one :user
  many_to_one :group

  def validate
    super
    validates_unique [:user_id, :group_id]
  end

  def admin?
    admin
  end

  def owner? 
    owner
  end
end


class Client < Sequel::Model
  one_to_many :projects
  many_to_one :group

  def validate
    super
    validates_presence :name
    validates_unique [:group_id, :name]
  end
end

class Project < Sequel::Model
  many_to_one :clients

  def validate
    super
    validates_presence :name
    validates_unique [:name, :client_id]
  end
end

class Project < Sequel::Model
  many_to_one :clients

  def validate
    super
    validates_presence [:name, :code]
    validates_unique [:name, :code, :client_id]

    validates_format /^\w+$/, :code
  end
end

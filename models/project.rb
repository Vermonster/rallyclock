class Project < Sequel::Model
  extend Forwardable

  many_to_one :client
  one_to_many :entries
  
  add_association_dependencies :entries => :destroy

  def rel_path
    "projects/#{code}"
  end

  delegate [:group] => :client


  def validate
    super
    validates_presence [:name, :code, :client_id]
    validates_unique [:name, :code, :client_id]

    validates_format /^\w+$/, :code
  end
end

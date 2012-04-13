class Project < Sequel::Model
  extend Forwardable

  many_to_one :client
  one_to_many :entries
  
  add_association_dependencies :entries => :destroy
  
  delegate [:group] => :client

  def rel_path
    "projects/#{code}"
  end
 
  def entries
    Entry.filter(project_id: id).all
  end

  # options:
  # to=YYYYMMDD
  # from=YYYMMDD
  def filter_entries(options={})
    if options.reject{|k,v|v.nil?}.empty?
      entries
    elsif options[:to] && options[:from]
      entries.select {|e| e.date <= Date.parse(options[:to]) && e.date >= Date.parse(options[:from])}
    elsif options[:to]
      entries.select {|e| e.date <= Date.parse(options[:to])}
    elsif options[:from]
      entries.select {|e| e.date >= Date.parse(options[:from])}
    end
  end

  def validate
    super
    validates_presence [:name, :code, :client_id]
    validates_unique [:name, :code, :client_id]

    validates_format /^\w+$/, :code
  end
end

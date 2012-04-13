class Client < Sequel::Model
  one_to_many :projects
  many_to_many :entries, :join_table => :projects
  many_to_one :group

  add_association_dependencies :projects => :destroy

  def rel_path
    "clients/#{account}"
  end

  def entries
    Entry.filter(project_id: projects_dataset.map(:id)).all
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
    validates_presence [:name, :account, :group_id]
    validates_unique [:group_id, :account, :name]
    validates_format /^\w+$/, :account
  end
end

require 'rspec/expectations'

module SequelMatchers
  extend RSpec::Matchers::DSL

  # validate_presence_of :name, :allow_nil => true
  # validate_format_of
  # validate_exact_length n
  # validate_min_length n
  # validate_max_length n
  # validate_length_range m..n
  # validate_integer
  # validate_numeric
  # validate_includes
  # validate_type
  # validate_not_string
  # validate_unique
  # restrict_access_to
  # allow_access_to
  # have_column :name, :type => :string
  # have_many_to_one
  # have_one_to_many
  # have_many_to_many
  # have_one_to_one

  matcher :have_many_to_one do |expected|
    match do |actual|
      return false unless ref = actual.class.association_reflection(expected)
      ref[:type] == :many_to_one
    end
  end
  
  matcher :have_one_to_many do |expected|
    match do |actual|
      return false unless ref = actual.class.association_reflection(expected)
      ref[:type] == :one_to_many
    end
  end
  
  matcher :have_many_to_many do |expected|
    match do |actual|
      return false unless ref = actual.class.association_reflection(expected)
      ref[:type] == :many_to_many
    end
  end
  
  matcher :have_one_to_one do |expected|
    match do |actual|
      return false unless ref = actual.class.association_reflection(expected)
      ref[:type] == :one_to_one
    end
  end

  matcher :have_column do |expected, options|
    match do |actual|
      (meta = actual.class.db_schema[expected]) && (options[:type] ? options[:type] == meta[:type] : true)
    end
  end
  
  matcher :restrict_access_to do |expected|
    match do |actual|
      !actual.class.allowed_columns.include?(expected)
    end
  end
end

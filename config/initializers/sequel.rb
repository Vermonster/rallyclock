class Sequel::Model
  plugin :json_serializer
  plugin :validation_helpers
  plugin :association_dependencies

  def before_create
    self.created_at ||= Time.now
    self.updated_at ||= Time.now
    super
  end

  def before_update
    self.updated_at = Time.now
    super
  end

  def uri_for(version)
    URI.join(ENV["SERVER"], RallyClock::API_v1.prefix, version, rel_path).to_s
  end

  def rel_path
    raise 'abstract'
  end

  undef each
end


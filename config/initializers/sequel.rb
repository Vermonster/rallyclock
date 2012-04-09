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
end


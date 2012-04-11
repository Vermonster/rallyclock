object @entry
attributes :note, :time
node(:user)    { |e| e.user.uri_for(@version) }
node(:group)   { |e| e.group.uri_for(@version) }
node(:project) { |e| e.project.uri_for(@version) }
node(:client)  { |e| e.client.uri_for(@version) }


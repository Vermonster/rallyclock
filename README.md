Rallyclock
==========

A [Grape](http://github.com/intridea/grape) API mounted on RACK.

### API (v.0.1.4)
##### All calls preceded by /api/&ltversion&gt
* GET /system/ping (sanity check)
* POST /users (creates new users)
* POST /sessions
* POST /groups
* DELETE /groups/:id
* POST /groups/:group_id/users
* PUT /groups/:group_id/users/:username
* DELETE /groups/:group_id/users/:username
* POST /groups/:group_id/clients
* PUT /groups/:group_id/clients/:id
* DELETE /groups/:group_id/clients/:id
* POST /groups/:group_id/clients/:client_id/projects
* PUT /groups/:group_id/clients/:client_id/projects/:id
* DELETE /groups/:group_id/clients/:client_id/projects/:id

TODOS:
both post and put should pass all attributes  
actions to activate/archive clients and projects  
missing actions  

  * GET /me
  * GET /groups/:id
  * PUT /groups/:id
  * GET /groups/:group_id/users
  * GET /groups/:group_id/users/:id
  * GET /groups/:group_id/clients
  * GET /groups/:group_id/clients/:id
  * GET /groups/:group_id/clients/:client_id/projects
  * GET /groups/:group_id/clients/:client_id/projects/:id
Tasks  
Invoices  
Reports  
Timers (proposed)  

  * POST /timer
  * DELETE /timer (results in an entry)
Entries (proposed)  

  * GET /today
  * GET /entries/YYYYMMDD
  * GET /entries?from=YYYYMMDD&to=YYYYMMDD (me)
  * GET /entries?from=YYYYMMDD&to=YYYYMMDD&active=true&billable=true&user_id=1,2,3 (admin)
  * POST /entries
  * POST /entries/import (batch import)
  * PUT /entries/:id
  * DELETE /entries/:id
  
Client Contacts  

Are the URLs too long? ("/clients", "/projects", "/users")  



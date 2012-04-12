Rallyclock
==========

A [Grape](http://github.com/intridea/grape) API mounted on RACK.

### API (v.0.2.13)
##### All calls preceded by /api/v1

( * admin priveleges necessary)

(Sanity Check)  
GET /system/ping  

(You)  
GET /me  
GET /me/projects  
GET /me/entries  
GET /me/entries/:id  
GET /me/entries?from=YYYYMMDD&to=YYYMMDD  

(Registration)  
POST /users  

(U+P Auth)  
POST /sessions  

(* Groups)
GET /groups/:id  
POST /groups  
DELETE /groups  

(* Members)  
GET /groups/:id/users
GET /groups/:id/users/:username
POST /groups/:id/users
PUT /groups/:id/users/:username  
DELETE /groups/:id/users/:username (delete membership)  

(* Clients)  
GET /groups/:id/clients
GET /groups/:id/clients/:account
POST /groups/:id/clients  
PUT /groups/:id/clients/:account  
DELETE /groups/:id/clients/:account  

(* Projects)  
GET /groups/:id/clients/:account/projects
GET /groups/:id/clients/:account/projects/:code  
POST groups/:id/clients/:account/projects  
PUT groups/:id/clients/:account/projects/:code  
DELETE groups/:id/clients/:account/projects/:code  

(* Entries)  
GET groups/:id/clients/:account/entries
GET groups/:id/clients/:account/entries?from=YYYYMMDD&to=YYYYMMDD
GET groups/:id/clients/:account/entries/:id  
GET groups/:id/projects/:code/entries  
GET groups/:id/projects/:code/entries?from=YYYYMMDD&to=YYYYMMDD
GET groups/:id/projects/:code/entries/:id
PUT groups/:id/projects/:code/entries/:id
DELETE groups/:id/projects/:code/entries/:id

API_v1 (the second coming)  
Tasks  
Invoices  
Reports  
Timers  
Client Contacts  

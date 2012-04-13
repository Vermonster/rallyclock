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
    GET /:handle  
    POST /groups (handle must be globally unique)  
    DELETE /:handle  

(* Members)  
    GET /:handle/users
    GET /:handle/users/:username
    POST /:handle/users
    PUT /:handle/users/:username  
    DELETE /:handle/users/:username (delete membership)  

(* Clients)  
    GET /:handle/clients
    GET /:handle/clients/:account
    POST /:handle/clients  
    PUT /:handle/clients/:account  
    DELETE /:handle/clients/:account  

(* Projects)  
    GET /:handle/clients/:account/projects
    GET /:handle/clients/:account/projects/:code  
    POST /:handle/clients/:account/projects  
    PUT /:handle/clients/:account/projects/:code  
    DELETE /:handle/clients/:account/projects/:code  

(* Entries) 
    GET /:handle/users/entries
    GET /:handle/users/entries?from=YYYYMMDD&to=YYYYMMDD
    GET /:handle/clients/:account/entries
    GET /:handle/clients/:account/entries?from=YYYYMMDD&to=YYYYMMDD
    GET /:handle/clients/:account/entries/:id  
    GET /:handle/projects/:code/entries  
    GET /:handle/projects/:code/entries?from=YYYYMMDD&to=YYYYMMDD
    GET /:handle/projects/:code/entries/:id
    PUT /:handle/projects/:code/entries/:id
    DELETE /:handle/projects/:code/entries/:id

API_v1 (the second coming/electric boogaloo/judgment day) 
Project Assignments
Tasks  
Invoices  
Reports  
Timers  
Client Contacts  

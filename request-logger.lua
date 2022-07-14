json = require("cjson")
local b64 = require("ngx.base64")
local ssl = require "ngx.ssl"

local data = {request={}}
local req = data["request"]
req["host"] = ngx.var.host
req["uri"] = ngx.var.uri
if ngx.req.get_headers()['user_agent'] then    
    req['user_agent'] = ngx.req.get_headers()['user_agent']
else
    req['user_agent'] = 'Unknown'
end
if ngx.req.get_headers()['authorization'] then
    -- We're assuming the auth header is HTTP Basic & Base64 encoded, update as per your requirement
    auth_header = ngx.req.get_headers()['authorization']
    i, j = string.find(auth_header, " ")
    decoded_value = b64.decode_base64url(string.sub(auth_header, i+1))
    k, l = string.find(decoded_value, ':')
    username = string.sub(decoded_value, 1, k-1)
    req['api_username'] = username
end
tls_version, err = ssl.get_tls1_version_str()
req['client_ip'] = ngx.var.remote_addr
req['tls_version'] = tls_version
req["time"] = ngx.req.start_time()
req["method"] = ngx.req.get_method()
-- Customise to capture usernames on login
if ngx.req.get_post_args()['username'] then
    req['username'] = ngx.req.get_post_args()['username']
end

local f = assert(io.open('/usr/local/openresty/nginx/logs/tls.log', "a"))
local file = io.open("/usr/local/openresty/nginx/logs/tls.log", "a")
file:write(json.encode(data) .. "\n")
file:close()

---------------------------------------------------------------------------------------------------------
-- Tundrawolf v1.0
--
-- A tiny demo only
-- Usage:
--	> # sudo ./nginx -p "${HOME}/tundrawolf/nginx"
--	> # ...
--	> curl -s -XPOST 'http://localhost/register' --data-binary @infra/samples/taskDef.json
--	> curl -s -XPOST --data 'y=aimingoo' 'http://localhost/execute?task:2996bf9b94ec7c2871642b6591486467'
---------------------------------------------------------------------------------------------------------

local Tundrawolf = require('lib.Distributed')
local dbg_resource_center = require('infra.dbg_resource_center')
local dbg_register_center = require('infra.dbg_register_center')
-- or install tundrawolf by luarocks, and then
-- local Tundrawolf = require('tundrawolf')
-- local dbg_resource_center = require('tundrawolf.dbg.resource_center')
-- local dbg_register_center = require('tundrawolf.dbg.register_center')

local options = {
	resource_status_center = dbg_resource_center,
	task_register_center = dbg_register_center,
	distributed_request = Tundrawolf.infra.httphelper.distributed_request,
}

local JSON = require('cjson')
local JSON_encode = JSON.encode
local JSON_decode = JSON.decode

local pedt = Tundrawolf:new(options)
local default_content_type = 'application/x-www-form-urlencoded'

local function error(reason)
	ngx.status = 500
	ngx.header.content_type = 'application/json'
	if type(reason) == 'table' then
		reason = JSON_encode(reason.reason or reason)
	else
		reason = JSON_encode(tostring(reason))
	end
	ngx.say(reason)
	ngx.exit(ngx.HTTP_OK)
end

local function success(taskResult)
	ngx.say(JSON_encode(taskResult))
	ngx.exit(ngx.HTTP_OK)
end

if ngx.var.request_method == 'POST' and ngx.var.uri == '/register' then
	ngx.req.read_body()
	if ngx.var.request_body then
		pedt:register_task(ngx.var.request_body):andThen(success, error)
	else
		error('Cant find data from POST request')
	end
end

if ngx.var.request_method == 'POST' and ngx.var.uri == '/execute' then
	ngx.req.read_body()
	local taskId, arguments = ngx.var.query_string, ngx.var.request_body
	local contentType = string.lower(ngx.var.content_type or default_content_type)

	if contentType == default_content_type then
		arguments = ngx.decode_args(arguments or "")
	elseif contentType == 'application/json' then
		arguments = JSON_decode(arguments or 'null')
	else
		error('Unsupported content-type: ' .. contentType)
	end

	pedt:execute_task(taskId, arguments):andThen(success, error)
end
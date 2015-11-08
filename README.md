#tundrawolf
tundrawolf is implement of PEDT - Parallel Exchangeable Distribution Task specifications for nginx_lua.

PEDT v1.1 specifications supported.

#install
> git clone https://github.com/aimingoo/tundrawolf

or
> luarocks install tundrawolf

#configurations in nginx.conf
First, append path to nginx.conf:
```conf
http {
	lua_package_path '...;${YOUR_Tundrawolf_DIR}/?.lua;;';
	...
```
> note1: you can skip package_path setting when tundrawolf installed by luarocks
> note2: @see $(Tundrawolf)/nginx/conf/nginx.conf

And next, add proxy_pass_interface in locatoin part:
```conf
http {
	...
	server {
		...
		location ~ ^/_/cast {
			## for default distributed_request interface in infra.httphelper, copy from:
			## 	$(Tundrawolf)/nginx/conf/nginx.conf
		}
```
for custom distributed_request interface/location, please copy $(tundrawolf)/infra/httphelper.lua to your project, change it and update location in nginx.conf.

#import and usage
Loading Tundrawolf into your source code:
```lua
-- require when installed by luarocks
local Tundrawolf = require('tundrawolf');

-- or hard load from lua_path/directory
-- local Tundrawolf = require('lib.Distributed');

local options = {};
local pedt = Tundrawolf:new(options);

pedt:run(..)
	:andThen(function(result){
		..
	})
```

## options
the full options schema:
```lua
options = {
	distributed_request = function(arrResult) .. end, -- a http client implement
	system_route = { .. }, -- any key/value pairs
	task_register_center = {
		download_task = function(taskId) .. end, -- PEDT interface
		register_task = function(taskDef) .. end,  -- PEDT interface
	},
	resource_status_center = {
		require = function(resId) .. end,-- PEDT interface
	}
}
```

## interfaces
> for detail, @see ${tundrawolf}/infra/specifications/*
> for Promise in lua, @see [https://github.com/aimingoo/Promise](https://github.com/aimingoo/Promise)

all interfaces are promise supported except pedt.upgrade() and helpers.

### pedt:run
```lua
function pedt:run(task, args)
```
run a task (taskId, function or taskObject) with args.

### pedt:map
```lua
function pedt:map(distributionScope, taskId, args)
```
map taskId to distributionScope with args, and get result array.

distributionScope will parse by pedt.require().

### pedt:execute_task
```lua
function pedt:execute_task(taskId, args)
```
run a taskId with args. pedt.run(taskId) will call this.

### pedt:register_task
```lua
function pedt:register_task(task)
```
run a task and return taskId.

the "task" is a taskDef text or local taskObject.

### pedt:require
```lua
function pedt:require(token)
```
require a resource by token. the token is distributionScope or system token, or other.

this is n4c expanded interface, resource query interface emmbedded.

### pedt:upgrade
```lua
function pedt:upgrade(newOptions)
```
upgrade current Tundrawolf/PEDT instance with newOptions. @see [options](#options)

this is tundrawolf expanded interface.

# helpers

some tool/helpers include in the package.

## Tundrawolf.infra.taskhelper
```lua
local Tundrawolf = require('tundrawolf');
local def = Tundrawolf.infra.taskhelper;
-- or
-- local def = require('tundrawolf.infra.taskhelper');

local taskDef = {
	x = def:run(...),
	y = def:map(...),
	...
}
```
a taskDef define helper.

## Tundrawolf.infra.httphelper
```lua
local Tundrawolf = require('tundrawolf');
local httphelper = Tundrawolf.infra.httphelper;
-- or
-- local httphelper = require('tundrawolf.infra.httphelper');

local options = {
	...,
	distributed_request = httphelper.distributed_request
}
```
a recommented/standard distributed request. @see:
> ${tundrawolf}/demo.lua

# system route discoveries in tundrawolf
in tundrawolf, you can register and discovery any system resources. for examples:
```lua
-- got system route discoveries
local Tundrawolf = require('tundrawolf')
local pedt = Tundrawolf:new({})
local system_route_discoveries = pedt:require('n4c.system.discoveries)

-- put your resources
local a_key, my_resource = "MY:RESOURCE_KEY", {} -- or anythings except false/nil in nginx_lua
local discoveries = {
	[a_key] = function() return my_resource end,
	-- more
}
table.foreach(discoveries, function(key, discoverer)
	system_route_discoveries[key] = discoverer
end)

-- usage
local res = pedt:require("MY:RESOURCE_KEY") -- a_key
```
all keys were cached always, so discoverer function call once  until you manual set invalid a_key:
```lua
pedt.upgrade({system_route = {[a_key] = false}})
```
for more example, @see [aimingoo/ngx_4c project](https://github.com/aimingoo/ngx_4c).

# testcase
try these:
```bash
> # goto home directory
> cd ~
> git clone 'https://github.com/aimingoo/tundrawolf'

> # goto nginx install direcotry
> # 	cd {$NGINX_HOME}/sbin
> ./nginx -p "${HOME}/tundrawolf/nginx"

> # goback and launch testcase
> go ~/tundrawolf/testcase
> bash test.sh
```

# history
```text
2015.11.09	v1.0.0 released.
```
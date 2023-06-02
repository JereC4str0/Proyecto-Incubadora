-----------------------------------------------------------------------------
--  This is the reference implementation to train lua fucntions. It
--  implements part of the core functionality and has some incomplete comments.
--
--  javier jorge
--
--  License:
-----------------------------------------------------------------------------
incubator = require("incubator")
require("SendToGrafana")
dofile('credentials.lua')

------------------------------------------------------------------------------------
-- ! @function temp_control 	     handles temperature control
-- ! @param temperature						 overall temperature
-- ! @param min_temp 							 temperature at which the resistor turns on
-- ! @param,max_temp 							 temperature at which the resistor turns off
------------------------------------------------------------------------------------


function temp_control(temperature, min_temp, max_temp)
   min_temp = 37.5
   max_temp = 38
    
    if temperature <= min_temp then
        incubator.heater(true)
    elseif temperature >= max_temp then
        incubator.heater(false)
    end -- end if

end -- end function

function read_and_control()
	temp,hum,pres=incubator.get_values()
	temp_control(temp, min_temp , max_temp)
end -- end function 

------------------------------------------------------------------------------------
-- ! @function read_and_send_data           is in charge of calling the read and  data sending
-- !                                    functions
------------------------------------------------------------------------------------
function read_and_send_data()
    send_data_grafana(incubator.temperature,incubator.humidity,incubator.pressure,INICIALES.."-bme")
end -- read_and_send_data end

function stop_rot()
    incubator.humidifier(false)
end

function rotate()
    incubator.humidifier(true)
    stoprotation = tmr.create()
    stoprotation:register(10000, tmr.ALARM_SINGLE, stop_rot)
    stoprotation:start()
end



incubator.init_values()
incubator.enable_testing(37.5,38,false)

local send_data_timer = tmr.create()
send_data_timer:register(3000, tmr.ALARM_AUTO, read_and_send_data)
send_data_timer:start()

local temp_control_timer = tmr.create()
temp_control_timer:register(1000, tmr.ALARM_AUTO, read_and_control)
temp_control_timer:start()

local rotation = tmr.create()
rotation:register(3600000, tmr.ALARM_AUTO, rotate)
rotation:start()


------------------------- API ------------------------
--* libraries

time = require("time")
sjson = require("sjson")


-------------------------------------
--! @function max_temp   print the current temperature
--
--!	@param req  				server request
-------------------------------------

function max_temp_get(req)
		
		local body_data = {
				message = "success",
                maxtemp = max_temp
				}

	    local body_json = sjson.encode(body_data)

	return {
			 status = "200 OK",
			 type = "application/json",
			 body = body_json
			 }
 
end -- end function

-------------------------------------
--! @function min_temp   print the current temperature
--
--!	@param req  				server request
-------------------------------------

function min_temp_get(req)
		
		local body_data = {
				message = "success",
                mintemp = min_temp
				}

	    local body_json = sjson.encode(body_data)

	return {
			 status = "200 OK",
			 type = "application/json",
			 body = body_json
			 }
 
end -- end function

--! @function maxtemp   print the current temperature
--
--!	@param req  				server request
-------------------------------------
function max_temp_post(req)    
    
	t = sjson.decode('{"key":"value"}')
	for k,v in pairs(t) do print(k,v) end 
	
    local reqbody = req.getbody()
    print(reqbody)
    
	local body_json = sjson.decode(reqbody)

    -- Obtener el nuevo valor de max_temp del cuerpo de la solicitud POST
    print(body_json.maxtemp)
    local new_max_temp = body_json.maxtemp

    -- Actualizar el valor de max_temp en el archivo incubator_controler.lua
    max_temp = new_max_temp
	

    return {
        status = "201 Created"
    }
end

--! @function maxtemp   print the current temperature
--
--!	@param req  				server request
-------------------------------------
function min_temp_post(req)    
    
	t = sjson.decode('{"key":"value"}')
	for k,v in pairs(t) do print(k,v) end 
	
    local reqbody = req.getbody()
    print(reqbody)
    
	local body_json = sjson.decode(reqbody)

    -- Obtener el nuevo valor de max_temp del cuerpo de la solicitud POST
    print(body_json.mintemp)
    local new_min_temp = body_json.mintemp

    -- Actualizar el valor de max_temp en el archivo incubator_controler.lua
    min_temp = new_min_temp
	

    return {
        status = "201 Created"
    }
end
-------------------------------------
--! @function date   		print the current date
--
--!	@param req  				server request
-------------------------------------

function date(req)
	local inc_date = time.get()
		local body_data = {
				message = "success",
				date = inc_date
				}

	return {
			 status = "200 OK",
			 type = "application/json",
			 body = sjson.encode(body_data)
			 }

end -- end function

-------------------------------------

-------------------------------------
--! @function version   print the current version
--
--!	@param req  				server request 
-------------------------------------




function version(req)
		
	local body_data = {
			message = "success",
			version = "0.0.1"
			}

	local body_json = sjson.encode(body_data)

	return {
			status = "200 OK",
			type = "application/json",
			body = body_json
			}

end -- end function

--* start local server

httpd.start({ webroot = "web", auto_index = httpd.INDEX_ALL})


--* dynamic routes to serve

httpd.dynamic(httpd.GET,"/version", version)
httpd.dynamic(httpd.GET,"/maxtemp", max_temp_get)
httpd.dynamic(httpd.POST,"/maxtemp", max_temp_post)
httpd.dynamic(httpd.GET,"/mintemp", min_temp_get)
httpd.dynamic(httpd.POST,"/mintemp", min_temp_post)
httpd.dynamic(httpd.GET,"/date", date)



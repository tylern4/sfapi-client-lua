local http=require("socket.http");
local url = require("socket.url")
local ltn12 = require("ltn12");
local json = require("json");

local sfapi = {}

function sfapi.get_sfapi_status(name) 
    local request_body = [[]]
    local response_body = {}
    local status = ""

    if name == nil then
        name = "perlmutter"
    end

    local res, code, response_headers = http.request{
        url = "https://api.nersc.gov/api/v1.2/status/" .. name,
        method = "GET", 
        headers = 
        {
            ["Content-Type"] = "application/x-www-form-urlencoded";
            ["Content-Length"] = #request_body;
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
    }


    if code == 200 then
        if type(response_body) == "table" then
            status = json.loads(table.concat(response_body))
        else
            print("Not a table:", type(response_body))
            os.exit(1)
        end
    end
    return status
end


function sfapi.is_active(name) 
    local status = sfapi.get_sfapi_status(name)
    for key, val in pairs(status) do
        if key == "status" and val == "active" then
            return true
        end
    end
    return false
end


function sfapi.user() 
    local request_body = [[]]
    local response_body = {}
    local status = ""

    local sfapi_token = os.getenv("SFAPI_TOKEN")
    if sfapi_token == nil then
        print("no token")
        os.exit(1)
    end

    local res, code, response_headers = http.request{
        url = "https://api.nersc.gov/api/v1.2/account",
        method = "GET", 
        headers = 
        {
            ["Content-Type"] = "application/x-www-form-urlencoded";
            ["Content-Length"] = #request_body;
            ["accept"] = "application/json";
            ["Authorization"] = "Bearer " .. sfapi_token;
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
    }

    if code == 200 then
        if type(response_body) == "table" then
            status = json.loads(table.concat(response_body))
        else
            print("Not a table:", type(response_body))
            os.exit(1)
        end
    end
    return status
end

return sfapi
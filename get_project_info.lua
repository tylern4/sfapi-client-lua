local sfapi_status = require "openapiclient.api.status_api"
local sfapi_accounts = require "openapiclient.api.account_api"


local sfapi_token = os.getenv("SFAPI_TOKEN")
if sfapi_token == nil then
    print("no token")
    os.exit(1)
end

local status = sfapi_status.new("api.nersc.gov", "/api/v1.2", { "https" })
local res = status:read_status_status_name_get("perlmutter")


print(res.status)

local scheme = { "https" }
local accounts = sfapi_accounts.new("api.nersc.gov", "/api/v1.2", scheme)
accounts.access_token = "Bearer " .. sfapi_token

local projects, headers = accounts:read_projects_account_projects_get()
if type(projects) == "table" then
    for _, line in ipairs(projects) do
        print(line.repo_name, line.id)
    end
end

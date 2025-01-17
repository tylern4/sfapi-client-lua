local sfapi_status = require "openapiclient.api.status_api"
local sfapi_accounts = require "openapiclient.api.account_api"
local sfapi_jobs = require "openapiclient.api.compute_api"

local sfapi_client = {}

local function get_token()
    local sfapi_token = os.getenv("SFAPI_TOKEN")
    if sfapi_token == nil then
        print("no token")
        os.exit(1)
    end
    return sfapi_token
end

local function check_status_before_run()
    local status = sfapi_status.new("api.nersc.gov", "/api/v1.2", { "https" })
    local res = status:read_status_status_name_get("perlmutter")
    if type(res) == "table" then
        print(res.status)
        if res.status == "active" then
            return true
        end
    end
    return false
end


function sfapi_client.GetProjects()
    local scheme = { "https" }
    local accounts = sfapi_accounts.new("api.nersc.gov", "/api/v1.2", scheme)
    accounts.access_token = "Bearer " .. get_token()
    local projects, headers, errors = accounts:read_projects_account_projects_get()
    if type(projects) == "table" then
        return projects
    else
        print("Error in GetProjects", headers, errors)
        os.exit(1)
    end
end

function sfapi_client.GetJobInfo(jobid)
    local scheme = { "https" }
    local jobs = sfapi_jobs.new("api.nersc.gov", "/api/v1.2", scheme)
    jobs.access_token = "Bearer " .. get_token()
    if not check_status_before_run() then
        print("Let me check on " .. jobid)
    end
    local jobinfo, headers, errors = jobs:read_job_compute_jobs_machine_jobid_get("perlmutter", jobid, "true", "false")
    if type(jobinfo) == "table" then
        return jobinfo
    else
        print("Error in GetJobInfo", headers, errors)
        os.exit(1)
    end
end

return sfapi_client

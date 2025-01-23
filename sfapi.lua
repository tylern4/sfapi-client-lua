local sfapi_status = require "sfapiclient.api.status_api"
local sfapi_accounts = require "sfapiclient.api.account_api"
local sfapi_jobs = require "sfapiclient.api.compute_api"
local sfapi_storage = require "sfapiclient.api.storage_api"

local sfapi_client = {}


local API_URL = "api-dev.nersc.gov"
local API_VER = "/api/v1.2"
local SCHEMES = { "https" }


local function get_token()
    local sfapi_token = os.getenv("SFAPI_TOKEN")
    if sfapi_token == nil then
        error("Error: no token")
        os.exit(1)
    end
    return sfapi_token
end

local function check_status_before_run()
    local status = sfapi_status.new(API_URL, API_VER, SCHEMES)
    local res = status:read_status_status_name_get("perlmutter")
    if type(res) == "table" then
        print(res.status)
        if res.status == "active" then
            return true
        end
    end
    return false
end

function sfapi_client.GetStatus()
    return check_status_before_run()
end

function sfapi_client.GetProjects()
    local accounts = sfapi_accounts.new(API_URL, API_VER, SCHEMES)
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
    local jobs = sfapi_jobs.new(API_URL, API_VER, SCHEMES)
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

function sfapi_client.StartGlobusTransfer(source_uuid, target_uuid, source_dir, target_dir, label)
    local storage = sfapi_storage.new(API_URL, API_VER, SCHEMES)
    storage.access_token = "Bearer " .. get_token()
    local result, headers, err = storage:start_globus_transfer_storage_globus_post(source_uuid, target_uuid, source_dir,
        target_dir, label)


    return result
end

function sfapi_client.GetGlobusTransfer(transfer_id)
    local storage = sfapi_storage.new(API_URL, API_VER, SCHEMES)
    storage.access_token = "Bearer " .. get_token()
    local result, headers, err = storage:check_globus_transfer_storage_globus_globus_uuid_get(transfer_id)


    return result
end

return sfapi_client

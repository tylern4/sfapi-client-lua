local sfapi = require "sfapi";


print("Getting status")
local status = sfapi.GetStatus()

print(tostring(status))


print("Getting projects")
local projects = sfapi.GetProjects()

for k, project_stats in pairs(projects) do
    print("======================")
    for key, project_stat in pairs(project_stats) do
        if type(project_stat) ~= "table" then
            print(key .. "=" .. project_stat)
        end
    end
end

local source_uuid = "dtn"
local target_uuid = "perlmutter"
local source_dir = "/global/cfs/cdirs/m3792/tylern/geant4.sif"
local target_dir = "/pscratch/sd/t/tylern/tmp"
local label = "Tranfer from lua"

local transfer = sfapi.StartGlobusTransfer(source_uuid, target_uuid, source_dir, target_dir, label)
print(transfer.transfer_id)

local result = sfapi.GetGlobusTransfer(transfer.transfer_id)

for key, val in pairs(result) do
    print(key .. "=====" .. val)
end

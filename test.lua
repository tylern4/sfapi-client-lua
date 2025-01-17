local sfapi = require "sfapi";



local projects = sfapi.GetProjects()

for i = 1, #projects do
    print(projects[i]["repo_name"])
end


local jobinfo = sfapi.GetJobInfo("31919318")

for k, v in pairs(jobinfo.output[1]) do
    print(k, v)
end

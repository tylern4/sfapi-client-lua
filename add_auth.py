from pathlib import Path


auth_path = """
\t-- Added by add_auth.py
\tif self.access_token ~= nil then
\t\treq.headers:upsert("authorization", self.access_token)
\tend
\t-- Added by add_auth.py
"""


for lua_file in Path().cwd().rglob("*.lua"):
    with lua_file.open('r') as in_file:
        buf = in_file.readlines()

    with lua_file.open('w') as out_file:
        for line in buf:
            if 'req.headers:upsert("content-type", "application/json")' in line:
                line += auth_path
            out_file.write(line)
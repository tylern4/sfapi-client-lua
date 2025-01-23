from pathlib import Path


auth_path = """
\t-- Added by add_auth.py
\tif self.access_token ~= nil then
\t\treq.headers:upsert("authorization", self.access_token)
\tend
\t-- Added by add_auth.py
"""


for lua_file in Path().cwd().rglob("*.lua"):
    did_file_get_updates = False
    with lua_file.open('r') as in_file:
        buf = in_file.readlines()

    with lua_file.open('w') as out_file:
        for line in buf:
            if 'req.headers:upsert("content-type", "application/json")' in line:
                did_file_get_updates = True
                line = line.replace("content-type", "accept")
                line += auth_path
            elif 'req.headers:upsert("accept", "application/x-www-form-urlencoded")' in line:
                line = line.replace('accept', 'content-type')
            out_file.write(line)
    if did_file_get_updates:
        print(f"Updated {lua_file.name}")

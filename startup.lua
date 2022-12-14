local version = "0.2"

shell.setPath(shell.path()..":/bin/programs")

_G.utils = require("/bin/apis/utils")

local latestVersion = http.get("https://raw.githubusercontent.com/PrincessCyanMarine/test/main/version").readAll()

if version ~= latestVersion then
    utils.downloadFromGithub("PrincessCyanMarine", "test", "main", "install.lua")
    os.run({}, "install.lua")
end
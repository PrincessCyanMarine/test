fs.delete("install.lua")
local baseURL = "https://api.github.com"

function downloadFromURL(url, path)
    local data = http.get({url=url, binary=true});
    if path == nil then
        error("No path given to download URL "..url, 1)
    end
    local file = fs.open(path, "wb");
    file.write(data.readAll())
    file.close()
end

function formURL(...)
    local url = arg[1]
    for i = 2, #arg do url = url.."/"..arg[i] end
    return url:gsub(" ", "%%20")
end

function downloadFromGithub(owner, repo, branch, path)
    if branch == nil then branch = "main" end
    local url = formURL("https://raw.githubusercontent.com", owner, repo, branch, path)
    downloadFromURL(url, path)
end

function getRepoContent(owner, repo, path)
    local url = utils.formURL(baseURL, "repos", owner, repo, "contents");
    if path ~= nil then url = utils.formURL(url, path) end
    local res = http.get(url);
    if res == nil then print("Couldn't get repo content"); return nil; end
    local code, text = res.getResponseCode()
    if code ~= 200 then print("ERROR: "..code); print(text); return nil; end
    local data_text  = res.readAll()
    local data = textutils.unserialiseJSON(data_text)
    res.close();
    return data;
end

function downloadRepo(owner, repo, path, downloadTo)
    if downloadTo == nil then downloadTo = "." end
    local content = getRepoContent(owner, repo, path);
    if content == nil then return end
    for index, value in ipairs(content) do
        if value.type == "file" then
            local save_path = downloadTo;
            if path ~= nil then save_path = save_path.."/"..path end
            print("Downloading "..save_path.."/"..value.name)
            downloadFromURL(value.download_url, save_path.."/"..value.name)
        else if value.type == "dir" then
            local actualPath = "";
            if path ~= nil then actualPath = path.."/"..value.name else actualPath = value.name end
            print("Opening "..actualPath)
            downloadRepo(owner, repo, actualPath, downloadTo)
        end
        end
    end
end

downloadRepo("PrincessCyanMarine", "test", "bin", ".")
downloadFromGithub("PrincessCyanMarine", "test", "main", "startup.lua")

os.reboot()
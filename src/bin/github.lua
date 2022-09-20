local TOKEN = nil

utils = require("utils")
local baseURL = "https://api.github.com"

function githubRequest(url) return http.get(url, utils.ternary(TOKEN, {Authorization="Bearer "..TOKEN}, nil));end

function getRepoContent(owner, repo, path)
    local url = utils.formURL(baseURL, "repos", owner, repo, "contents");
    if path ~= nil then url = utils.formURL(url, path) end
    local res = githubRequest(url);
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
            utils.downloadFromURL(value.download_url, save_path.."/"..value.name)
        else if value.type == "dir" then
            local actualPath = "";
            if path ~= nil then actualPath = path.."/"..value.name else actualPath = value.name end
            print("Opening "..actualPath)
            downloadRepo(owner, repo, actualPath, downloadTo)
        end
        end
    end
end
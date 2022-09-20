local TOKEN = "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"
local baseURL = "https://api.github.com"

function formURL(...)
    local url = arg[1]
    for i = 2, #arg do url = url.."/"..arg[i] end
    return url:gsub(" ", "%%20")
end

function ternary(condition, ifTrue, ifFalse)
    if condition then return ifTrue
    else return ifFalse end
end
function githubRequest(url) return http.get(url, ternary(TOKEN, {Authorization="Bearer "..TOKEN}, nil));end

function checkForLatestReleaseUpdate(owner, repo, currentVersion)
    local response = getLatestRelease(owner, repo)
    if response == nil then return nil end
    local code, text = response.getResponseCode();
    if code == 200 then
        local release = textutils.unserialiseJSON(response.readAll());
        if release.name ~= currentVersion then return release; end
    else print("ERROR: "..code); print(text) end
    return nil
end

function downloadLatestRelease(owner, repo, path)
    print("Downloading latest release from "..formURL("https://github.com", owner, repo));
    local response = getLatestRelease(owner, repo);
    if response == nil then print("No releases found"); return; end
    local code, text = response.getResponseCode();
    if code == 200 then
        local release = textutils.unserialiseJSON(response.readAll());
        if path == nil then path = "./downloads/github/"..owner.."/"..repo.."/"..release.name end
        downloadRelease(release, path);
    else print(text) end
    response.close();
    print("Finished download");
end

function getLatestRelease(owner, repo) return githubRequest(formURL(baseURL, "repos", owner, repo, "releases/latest")); end

function downloadRelease(release, path)
    if path == nil then path = "./downloads/"..release.name end
    print("Latest release: "..release.name);
    for index, value in ipairs(release.assets) do
        print("Downloading "..value.name);
        downloadFromURL(value.browser_download_url, path.."/"..value.name)
    end
end

function downloadFromURL(url, path)
    local data = http.get({url=url, binary=true});
    local file = fs.open(path, "wb");
    file.write(data.readAll())
    file.close()
end

function writeToFile(path, content) 
    local file = fs.open(path, "w");
    file.write(content)
    file.close()
end

function getRepoContent(owner, repo, path)
    local url = formURL(baseURL, "repos", owner, repo, "contents");
    if path ~= nil then url = formURL(url, path) end
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
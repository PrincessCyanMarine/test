utils = require("utils")
local baseURL = "https://api.github.com"

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
    print("Downloading latest release from "..utils.formURL("https://github.com", owner, repo));
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

function getLatestRelease(owner, repo) return githubRequest(utils.formURL(baseURL, "repos", owner, repo, "releases/latest")); end

function downloadRelease(release, path)
    if path == nil then path = "./downloads/"..release.name end
    print("Latest release: "..release.name);
    for index, value in ipairs(release.assets) do
        print("Downloading "..value.name);
        utils.downloadFromURL(value.browser_download_url, path.."/"..value.name)
    end
end
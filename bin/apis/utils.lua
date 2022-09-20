local utils = {}

utils.downloadFromURL = function (url, path)
    local data = http.get({url=url, binary=true});
    if path == nil then error("No path given to download URL "..url, 1) end
    local file, reason = fs.open(path, "wb");
    if file == nil then
        print(reason)
        return
    end
    file.write(data.readAll())
    file.close()
end

utils.ternary = function (condition, ifTrue, ifFalse)
    if condition then return ifTrue
    else return ifFalse end
end

utils.formURL = function (...)
    local url = arg[1]
    for i = 2, #arg do url = url.."/"..arg[i] end
    return url:gsub(" ", "%%20")
end

utils.writeToFile = function (path, content)
    local file = fs.open(path, "w");
    file.write(content)
    file.close()
end

utils.downloadFromGithub = function (owner, repo, branch, path)
    if branch == nil then branch = "main" end
    local url = formURL("https://raw.githubusercontent.com", owner, repo, branch, path)
    downloadFromURL(url, path)
end

return utils
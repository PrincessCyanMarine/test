local utils = {}

utils.downloadFromURL = function (url, path)
    local data = http.get({url=url, binary=true});
    local file = fs.open(path, "wb");
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

return utils
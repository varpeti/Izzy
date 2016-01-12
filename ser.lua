--Borrowed table persistence from http://lua-users.org/wiki/TablePersistence, MIT license.
--comments removed, condensed code to oneliners where possible.

local write, writeIndent, writers, refCount, persistence;

write = function (file, item, level, objRefNames)
    writers[type(item)](file, item, level, objRefNames);
end;

writeIndent = function (file, level)
    for i = 1, level do
        file:write("\t");
    end;
end;

refCount = function (objRefCount, item)
    if type(item) == "table" then
        if objRefCount[item] then
            objRefCount[item] = objRefCount[item] + 1;
        else
            objRefCount[item] = 1;
            for k, v in pairs(item) do
                refCount(objRefCount, k);
                refCount(objRefCount, v);
            end;
        end;
    end;
end;

writers = {
    ["nil"] = function (file, item) file:write("nil") end;
    ["number"] = function (file, item)
            file:write(tostring(item));
        end;
    ["string"] = function (file, item)
            file:write(string.format("%q", item));
        end;
    ["boolean"] = function (file, item)
            if item then
                file:write("true");
            else
                file:write("false");
            end
        end;
    ["table"] = function (file, item, level, objRefNames)
            local refIdx = objRefNames[item];
            if refIdx then
                file:write("multiRefObjects["..refIdx.."]");
            else
                file:write("{\n");
                for k, v in pairs(item) do
                    writeIndent(file, level+1);
                    file:write("[");
                    write(file, k, level+1, objRefNames);
                    file:write("] = ");
                    write(file, v, level+1, objRefNames);
                    file:write(";\n");
                end
                writeIndent(file, level);
                file:write("}");
            end;
        end;
    ["function"] = function (file, item)
            local dInfo = debug.getinfo(item, "uS");
            if dInfo.nups > 0 then
                file:write("nil --[[functions with upvalue not supported]]");
            elseif dInfo.what ~= "Lua" then
                file:write("nil --[[non-lua function not supported]]");
            else
                local r, s = pcall(string.dump,item);
                if r then
                    file:write(string.format("loadstring(%q)", s));
                else
                    file:write("nil --[[function could not be dumped]]");
                end
            end
        end;
    ["thread"] = function (file, item)
            file:write("nil --[[thread]]\n");
        end;
    ["userdata"] = function (file, item)
            file:write("nil --[[userdata]]\n");
        end;
}

persistence =
{
    store = function (path, ...)
        local file, e = io.open(path, "w")
        if not file then return error(e)    end
        local n = select("#", ...)
        local objRefCount = {} -- Stores reference that will be exported
        for i = 1, n do refCount(objRefCount, (select(i,...))) end
        local objRefNames = {}
        local objRefIdx = 0;
        file:write("-- Persistent Data\n");
        file:write("local multiRefObjects = {\n");
        for obj, count in pairs(objRefCount) do
            if count > 1 then
                objRefIdx = objRefIdx + 1;
                objRefNames[obj] = objRefIdx;
                file:write("{};"); -- table objRefIdx
            end;
        end;
        file:write("\n} -- multiRefObjects\n");
        for obj, idx in pairs(objRefNames) do
            for k, v in pairs(obj) do
                file:write("multiRefObjects["..idx.."][");
                write(file, k, 0, objRefNames);
                file:write("] = ");
                write(file, v, 0, objRefNames);
                file:write(";\n");
            end;
        end;
        for i = 1, n do
            file:write("local ".."obj"..i.." = ");
            write(file, (select(i,...)), 0, objRefNames);
            file:write("\n");
        end
        if n > 0 then
            file:write("return obj1");
            for i = 2, n do
                file:write(" ,obj"..i);
            end;
            file:write("\n");
        else
            file:write("return\n");
        end;
        file:close();
    end;
    load = function (path)
        local f, e = loadfile(path);
        if f then
            return f();
        else
            return nil, e;
        end;
    end;
}

return persistence
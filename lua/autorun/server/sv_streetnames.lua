util.AddNetworkString("StreetNames:CreateStreet")
util.AddNetworkString("StreetNames:DeleteStreet")

if not file.IsDir("streetnames","DATA") then
    file.CreateDir("streetnames")
end
if not file.Exists("streetnames/"..game.GetMap()..".txt", "DATA") then
    file.Write("streetnames/"..game.GetMap()..".txt", "{}")
end

local streetTableCache = false

net.Receive("StreetNames:CreateStreet", function(len,ply)

    if not ply:IsSuperAdmin() then return end

    local name = net.ReadString()
    local vecTable = net.ReadTable()
    if table.IsEmpty(vecTable) then return end

    

    local str = file.Read("streetnames/"..game.GetMap()..".txt", "DATA")
    local dataTable = util.JSONToTable(str)

    dataTable[name] = dataTable[name] or {}

    for _,v in pairs(vecTable) do
        dataTable[name][#dataTable[name] + 1] = {
            vec1 = v.vec1,
            vec2 = v.vec2
        }
    end

    file.Write("streetnames/"..game.GetMap()..".txt", util.TableToJSON(dataTable))

    streetTableCache = dataTable

    net.Start("StreetNames:CreateStreet")
    net.WriteTable(streetTableCache)
    net.Broadcast()
    

end)

net.Receive("StreetNames:DeleteStreet", function(len,ply)

    if not ply:IsSuperAdmin() then return end
    local sn = net.ReadString()
    local str = file.Read("streetnames/"..game.GetMap()..".txt", "DATA")
    local dataTable = util.JSONToTable(str)
    dataTable[sn] = nil
    file.Write("streetnames/"..game.GetMap()..".txt", util.TableToJSON(dataTable))
    streetTableCache = dataTable
    net.Start("StreetNames:CreateStreet")
    net.WriteTable(streetTableCache)
    net.Broadcast()
    
end)

hook.Add("PlayerSpawn", "StreetNames:PS", function(ply)
    if not streetTableCache then
        local str = file.Read("streetnames/"..game.GetMap()..".txt", "DATA")
        streetTableCache = util.JSONToTable(str or "{}")
    end
    
    if table.IsEmpty(streetTableCache) then return end

    net.Start("StreetNames:CreateStreet")
    net.WriteTable(streetTableCache)
    net.Send(ply)
end)
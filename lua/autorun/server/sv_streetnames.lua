util.AddNetworkString("StreetNames:CreateStreet")
util.AddNetworkString("StreetNames:DeleteStreet")
util.AddNetworkString("StreetNames:SendEntity")

if not file.IsDir("streetnames","DATA") then
    file.CreateDir("streetnames")
end
if not file.Exists("streetnames/"..game.GetMap()..".txt", "DATA") then
    file.Write("streetnames/"..game.GetMap()..".txt", "{}")
end

local streetTableCache = false
local intTable = {}

local function createStreetEnt()

    local str = file.Read("streetnames/"..game.GetMap()..".txt", "DATA")
    local dataTable = util.JSONToTable(str)

    for _,ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "streetname_ent" then ent:Remove() end
    end

    i = 1

    intTable = {}

    for streetname,routes in pairs(dataTable) do

        table.insert(intTable, streetname)
        
        for _,streets in pairs(routes) do

            local route = ents.Create("streetname_ent")
            route:Spawn()
            route:SetCollisionBoundsWS(streets.vec1, streets.vec2)
            route:SetRouteID(i)

            function route:StartTouch( eEnt )
                if not IsValid(eEnt) then return end
                if not eEnt:IsPlayer() then return end
                net.Start("StreetNames:SendEntity")
                net.WriteUInt(route:GetRouteID(), 16)
                net.Send(eEnt)
            end

        end

        i = i + 1

    end

end

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

    createStreetEnt()

    net.Start("StreetNames:CreateStreet")
    net.WriteTable(streetTableCache)
    net.WriteTable(intTable)
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

    createStreetEnt()

    net.Start("StreetNames:CreateStreet")
    net.WriteTable(streetTableCache)
    net.WriteTable(intTable)
    net.Broadcast()
    
end)

hook.Add("PlayerSpawn", "StreetNames:PS", function(ply)

    if not streetTableCache then
        local str = file.Read("streetnames/"..game.GetMap()..".txt", "DATA")
        local dataTable = util.JSONToTable(str and str or "{}")
        streetTableCache = dataTable
    end

    net.Start("StreetNames:CreateStreet")
    net.WriteTable(streetTableCache)
    net.WriteTable(intTable)
    net.Send(ply)
end)



createStreetEnt()

hook.Add("OnGamemodeLoaded", "StreetNames:OGL", function()
    createStreetEnt()
    hook.Remove("OnGamemodeLoaded", "StreetNames:OGL")
end)
local mt_Player = FindMetaTable( "Player" )

if SERVER then

    function mt_Player:GetCurrentRoad()
        return self.tRoads and self.tRoads[ #self.tRoads ] or false
    end

    function mt_Player:GetCurrentRoadID()
        return self.tRoads and IsValid(self.tRoads[ #self.tRoads ]) and self.tRoads[ #self.tRoads ]:GetRouteID() or false
    end

end

function mt_Player:GetCurrentRoadName()
    if SERVER then
        return self.tRoads and IsValid(self.tRoads[ #self.tRoads ]) and self.tRoads[ #self.tRoads ]:GetRouteName() or false
    end

    if CLIENT then
        return StreetNames.CurrentStreet and StreetNames.CurrentStreet or false
    end
end
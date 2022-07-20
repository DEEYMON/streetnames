ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "RouteID" )
end
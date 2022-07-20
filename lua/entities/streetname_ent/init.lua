AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetSolid( SOLID_BBOX )
end

function ENT:StartTouch( eEntity )

end

function ENT:EndTouch( eEntity )

end
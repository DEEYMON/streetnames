StreetNames = StreetNames or {}
StreetNames.Streets = StreetNames.Streets or {}
StreetNames.StreetColors = StreetNames.StreetColors or {}

StreetNames.ColorList = {
    [1] = Color(50,0,0,100),
    [2] = Color(50,50,0,100),
    [3] = Color(50,50,50,100),
    [4] = Color(0,50,0,100),
    [5] = Color(0,50,50,100),
    [6] = Color(0,0,50,100),
    [7] = Color(100,0,0,100),
    [8] = Color(100,100,0,100),
    [9] = Color(100,100,100,100),
    [10] = Color(0,100,0,100),
    [11] = Color(0,100,100,100),
    [12] = Color(0,0,100,100),
    [13] = Color(200,0,0,100),
    [14] = Color(200,200,0,100),
    [15] = Color(200,200,200,100),
    [16] = Color(0,200,0,100),
    [17] = Color(0,200,200,100),
    [18] = Color(0,0,200,100),
}

TOOL.Category = "Street Names"

TOOL.Name = "#tool.streetnames.name"
TOOL.Command = nil
TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" },
    { name = "use" },
}

TOOL.BoxInformations = {}
TOOL.BoxInformations.Vectors = {}
TOOL.FirstInit = false
TOOL.StreetColors = {}

if CLIENT then
    language.Add( "tool.streetnames.name", "Street Names Tool" )
    language.Add( "Tool.streetnames.desc", "Tool to define and edit street names" )
    language.Add( "Tool.streetnames.left", "Set the positions of the box" )
    language.Add( "Tool.streetnames.right", "Reset selection" )
    language.Add( "Tool.streetnames.reload", "See current streets" )
    language.Add( "Tool.streetnames.reload_right", "" )
    language.Add( "Tool.streetnames.use", "Set positions of the box to your location" )
end

function TOOL:LeftClick( trace )
    if not IsFirstTimePredicted() then return end
    local ply = self.Owner
    if not IsValid(ply) then return end
	if CLIENT then
        if not ply:IsSuperAdmin() then return end

        if not trace.Hit then return end
        if #self.BoxInformations.Vectors == 2 then self.BoxInformations.Vectors = {} end
        self.BoxInformations.Vectors[#self.BoxInformations.Vectors + 1] = trace.HitPos

        if #self.BoxInformations.Vectors == 2 then
            StreetNames:CreateStreet(self.BoxInformations)
            StreetNames.IsAdding = false
            self.BoxInformations.Vectors = {}
        end
    end

    return false
end

if CLIENT then
    hook.Add("KeyPress", "StreetNames:KeyPress", function(ply,key)
        if not IsFirstTimePredicted() then return end
        if key ~= IN_USE then return end
        local plywep = ply:GetActiveWeapon()
        if not IsValid(plywep) then return end
        if plywep:GetClass() ~= "gmod_tool" then return end
        local tool = ply:GetTool()
        if tool.Mode ~= "streetnames" then return end
        if not ply:IsSuperAdmin() then return end

        local trace = { Hit = true, HitPos = ply:GetPos() }
        tool:LeftClick(trace)
        
    end)
end

function TOOL:RightClick()
    if CLIENT then
        if not IsFirstTimePredicted() then return end
        local ply = self.Owner
        if not IsValid(ply) then return end
        if CLIENT then
            if not ply:IsSuperAdmin() then return end

            self.BoxInformations.Vectors = {}
        end
    end

    return false
end

function TOOL:Deploy()
    if CLIENT then
        self.holster = false
        StreetNames.IsAdding = false
        local ply = self.Owner
        self.FirstInit = true
        if not ply:IsSuperAdmin() then return end

        hook.Add( "PostDrawTranslucentRenderables", "StreetNames:PDTR", function()

            if self.ShowStreets then
                for streetname,routes in pairs(StreetNames.Streets) do
                    for _,streets in pairs(routes) do
                        render.SetColorMaterial()
                        cam.IgnoreZ(true)
                        render.DrawWireframeBox( streets.vec1, angle_zero, Vector(0,0,0), streets.vec2 - streets.vec1, color_white )
                        render.DrawBox( streets.vec1, angle_zero, Vector(0,0,0), streets.vec2 - streets.vec1, StreetNames.StreetColors[streetname], true )
                        cam.IgnoreZ(false)
                    end
                end
            end

            if not self.BoxInformations.Vectors[1] then return end
            local tr = ply:GetEyeTrace()
            local orVec = Vector(0,0,0)
            if tr.Hit then orVec = tr.HitPos end
            local vec1 = self.BoxInformations.Vectors[1]
            local vec2 = self.BoxInformations.Vectors[2] and self.BoxInformations.Vectors[2] or orVec

            render.SetColorMaterial()
            cam.IgnoreZ(true)
            render.DrawWireframeBox( vec1, angle_zero, Vector(0,0,0), vec2 - vec1, color_white )
            render.DrawBox( vec1, angle_zero, Vector(0,0,0), vec2 - vec1, Color(0,100,0,100), true )
            cam.IgnoreZ(false)

        end )
    end
end

function TOOL:Reload()
    if CLIENT then
        local ply = self.Owner

        if not IsFirstTimePredicted() then return end
        if not ply:IsSuperAdmin() then return end
        self.ShowStreets = not self.ShowStreets
        StreetNames.ShowStreets = self.ShowStreets

        if not self.ShowStreets then return end
        local i = 0
        for streetname,routes in pairs(StreetNames.Streets) do
            i = i + 1
            StreetNames.StreetColors[streetname] = StreetNames.ColorList[i]
        end

    end
end

function TOOL:Think()
    if CLIENT then
        local ply = self.Owner
        if not ply:IsSuperAdmin() then return end
        if not self.FirstInit or self.holster then self:Deploy() end
    end
end

function TOOL:Holster()
    if CLIENT then
        local ply = self.Owner
        if not ply:IsSuperAdmin() then return end
        self.holster = true
        self.ShowStreets = false
        StreetNames.ShowStreets = false
        self.BoxInformations.Vectors = {}
        hook.Remove("PostDrawTranslucentRenderables", "StreetNames:PDTR")
        StreetNames.IsAdding = false
    end
end

function TOOL.BuildCPanel( panel, nope )
    panel:Button( "Street admin panel", "streetnames_admin" )

end
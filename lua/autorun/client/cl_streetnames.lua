StreetNames = StreetNames or {}
StreetNames.Streets = StreetNames.Streets or {}
StreetNames.StreetColors = StreetNames.StreetColors or {}
StreetNames.AddStreetFrame = {}

StreetNames.IsAdding = false


local lastStreet = "Unknown"
local lastIntersection = "Unknown"
local facing = "N"

local iLastScreenH = false 
local iMargin, iRoundness
local function scaleVGUI()
    local iH = ScrH()

    if iLastScreenH and ( iLastScreenH == iH ) then
        return iMargin, iRoundness
    end

    local ceil = math.ceil
    local iFontSize1, iFontSize2, iFontSize3 = ceil( iH * .035 ), ceil( iH * .03 ), ceil( iH * .02 )

    surface.CreateFont( "StreetNames.Main", { font = "Rajdhani Medium", size = iFontSize1 } )
    surface.CreateFont( "StreetNames.Street", { font = "Rajdhani Medium", size = iFontSize2 } )
    surface.CreateFont( "StreetNames.Vec", { font = "Rajdhani Medium", size = iFontSize3 } )
    iLastScreenH, iMargin, iRoundness = iH, ceil( iH * .008 ), ceil( iH * .006 )

    return iMargin, iRoundness
end


net.Receive("StreetNames:CreateStreet", function(len)
    local data = net.ReadTable()
    StreetNames.Streets = data
end)

streetTable = {}


function StreetNames:CreateStreet(data)

    scaleVGUI()

    if not LocalPlayer():IsSuperAdmin() then return end

    StreetNames.AddStreetFrame = vgui.Create("DFrame")
    local main = StreetNames.AddStreetFrame
    main:SetSize(ScrW() * .2, ScrH() * .4)
    main:MakePopup()
    main:Center()
    main:SetTitle("")
    main:ShowCloseButton(false)
    function main:Paint(w,h)
        surface.SetDrawColor(Color(31,31,31))
        surface.DrawRect(0,0,w,h)
    end

    local streetnamelabel = vgui.Create("DLabel", main)
    streetnamelabel:SetSize(main:GetWide() * .5, main:GetTall() * .1)
    streetnamelabel:SetFont("StreetNames.Main")
    streetnamelabel:SetText("Street Name")
    streetnamelabel:SizeToContentsX()
    streetnamelabel:SetPos( ( main:GetWide() / 2 ) - ( streetnamelabel:GetWide() / 2 ), main:GetTall() * .1)
    streetnamelabel:SetColor(Color(255,255,255))

    local streetname = vgui.Create("DTextEntry", main)
    streetname:SetFont("StreetNames.Main")
    streetname:SetPlaceholderText("Street Name")
    streetname:SetSize(main:GetWide() * .7, main:GetTall() * .1)
    streetname:SetPos(main:GetWide() * .15, main:GetTall() * .2)
    streetname:SetUpdateOnType(true)

    local streetlistlabel = vgui.Create("DLabel", main)
    streetlistlabel:SetSize(main:GetWide() * .5, main:GetTall() * .1)
    streetlistlabel:SetFont("StreetNames.Main")
    streetlistlabel:SetText("Street List")
    streetlistlabel:SizeToContentsX()
    streetlistlabel:SetPos( ( main:GetWide() / 2 ) - ( streetlistlabel:GetWide() / 2 ), main:GetTall() * .3)
    streetlistlabel:SetColor(Color(255,255,255))
    StreetNames.AddStreetFrame.StreetList = vgui.Create("DScrollPanel", main)
    local streetList = StreetNames.AddStreetFrame.StreetList

    streetList:SetSize(main:GetWide() * .7, main:GetTall() * .4)
    streetList:SetPos(main:GetWide() * .15, main:GetTall() * .4)

    local sbar = streetList:GetVBar()
    function sbar:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end

    streetTable[#streetTable + 1] = {
        vec1 = data.Vectors[1],
        vec2 = data.Vectors[2]
    }

    for k,v in pairs(streetTable) do

        local vec1,vec2,vec3 = v.vec1:Unpack()
        vec1,vec2,vec3 = math.Round(vec1,2), math.Round(vec2,2), math.Round(vec3,2)

        local streetFrame = streetList:Add("DPanel")
        streetFrame:SetSize(streetList:GetWide(), streetList:GetTall() * .3)
        streetFrame:Dock(TOP)
        streetFrame:DockMargin(0,0,0,5)
        function streetFrame:Paint(w,h)
            surface.SetDrawColor(Color(51,51,51))
            surface.DrawRect(0,0,w,h)
        end

        local streetpos1 = vgui.Create("DLabel", streetFrame)
        streetpos1:SetSize(streetFrame:GetWide() * .9, streetFrame:GetTall() * .3)
        streetpos1:SetPos(streetFrame:GetWide() * .01, streetFrame:GetTall() * .1)
        streetpos1:SetFont("StreetNames.Vec")
        streetpos1:SetText("Pos 1: "..vec1..","..vec2..","..vec3)
        streetpos1:SetColor(Color(255,255,255))

        vec1,vec2,vec3 = v.vec2:Unpack()
        vec1,vec2,vec3 = math.Round(vec1,2), math.Round(vec2,2), math.Round(vec3,2)

        local streetpos2 = vgui.Create("DLabel", streetFrame)
        streetpos2:SetSize(streetFrame:GetWide() * .9, streetFrame:GetTall() * .3)
        streetpos2:SetPos(streetFrame:GetWide() * .01, streetFrame:GetTall() * .5)
        streetpos2:SetFont("StreetNames.Vec")
        streetpos2:SetText("Pos 2: "..vec1..","..vec2..","..vec3)
        streetpos2:SetColor(Color(255,255,255))


        local remove = vgui.Create("DButton", streetFrame)
        remove:SetText("X")
        remove:SetFont("StreetNames.Main")
        remove:SetSize(streetFrame:GetTall() * .8,streetFrame:GetTall() * .8)
        remove:SetColor(Color(255,255,255))
        remove:SetPos(streetFrame:GetWide() * .82, ( streetFrame:GetTall() / 2 ) - ( streetFrame:GetTall() * .8 / 2 ))
        function remove:Paint(w,h)
            surface.SetDrawColor(Color(100,0,0))
            surface.DrawRect(0,0,w,h)
        end

        function remove:DoClick()
            table.remove(streetTable, k)
            streetFrame:Remove()
        end

    end

    local addBtn = streetList:Add("DButton")
    addBtn:SetSize(streetList:GetWide(), streetList:GetTall() * .2)
    addBtn:Dock(TOP)
    addBtn:SetText("Add vector")
    addBtn:SetFont("StreetNames.Main")
    addBtn:SetColor(Color(255,255,255))
    addBtn:DockMargin(0,0,0,5)
    function addBtn:Paint(w,h)
        surface.SetDrawColor(Color(0,100,0))
        surface.DrawRect(0,0,w,h)
    end

    function addBtn:DoClick()
        StreetNames.IsAdding = true
        main:Remove()
    end

    local accept = vgui.Create("DButton", main)
    accept:SetSize(main:GetWide() * .35, main:GetTall() * .1)
    accept:SetPos(main:GetWide() * .1, main:GetTall() * .85)
    accept:SetColor(Color(255,255,255))
    accept:SetText("Accept")
    accept:SetFont("StreetNames.Main")
    function accept:Paint(w,h)
        surface.SetDrawColor(Color(0,100,0))
        surface.DrawRect(0,0,w,h)
    end
    function accept:DoClick()
        net.Start("StreetNames:CreateStreet")
        net.WriteString(streetname:GetValue())
        net.WriteTable(streetTable)
        net.SendToServer()
        main:Remove()
        StreetNames.IsAdding = false
        streetTable = {}
    end

    local cancel = vgui.Create("DButton", main)
    cancel:SetSize(main:GetWide() * .35, main:GetTall() * .1)
    cancel:SetPos(main:GetWide() * .55, main:GetTall() * .85)
    cancel:SetColor(Color(255,255,255))
    cancel:SetText("Cancel")
    cancel:SetFont("StreetNames.Main")
    function cancel:Paint(w,h)
        surface.SetDrawColor(Color(100,0,0))
        surface.DrawRect(0,0,w,h)
    end
    function cancel:DoClick()
        main:Remove()
        StreetNames.IsAdding = false
        streetTable = {}
    end
    

end

streetHud = {}
function StreetNames:CreateHUD()
    scaleVGUI()
    streetHud = vgui.Create("DPanel")
    streetHud:SetSize(ScrW() * .26, ScrH() * .03)
    streetHud:SetPos(ScrW() * .15, ScrH() * .96)
    streetHud:SetPaintedManually(true)
    function streetHud:Paint(w,h)

        facing = ( EyeAngles()[2] <= 45 and EyeAngles()[2] >= -45 ) and "N" or ( EyeAngles()[2] >= 45.001 and EyeAngles()[2] <= 135 ) and "W" or ( EyeAngles()[2] >= 135.001 or EyeAngles()[2] <= -135 ) and "S" or ( EyeAngles()[2] >= -135.001 and EyeAngles()[2] <= -45.001 ) and "E"

        surface.SetDrawColor(100,100,100,150)
        surface.DrawRect(0,0,w*0.015,h)

        surface.SetDrawColor(100,100,100,150)
        surface.DrawRect(w*.075,0,w*0.015,h)

        draw.SimpleTextOutlined(facing, "StreetNames.Main", w*.09/2,h/2,Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0))
        draw.SimpleTextOutlined(lastStreet .. " / ", "StreetNames.Street", w*.095,h/2,Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0))
        surface.SetFont("StreetNames.Street")
        local x,y = surface.GetTextSize(lastStreet .. " / ")
        draw.SimpleTextOutlined(lastIntersection, "StreetNames.Street", w*.095 + x,h/2,Color(255,193,23), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0))
    end
end




hook.Add("HUDPaint", "SteetNames:HUDPaint", function()
    local ply = LocalPlayer()
    for streetname,routes in pairs(StreetNames.Streets) do
        for _,streets in pairs(routes) do
            if ply:GetPos():WithinAABox(streets.vec1, streets.vec2) then
                local last = lastIntersection
                lastIntersection = lastStreet
                lastStreet = streetname
                if lastIntersection == lastStreet then lastIntersection = last end
            end
        end
    end

    if not IsValid(streetHud) then StreetNames:CreateHUD() end
    streetHud:PaintManual()

    if StreetNames.ShowStreets then
        local i = 1
        for streetname,routes in pairs(StreetNames.Streets) do
            for _,streets in pairs(routes) do
                local r,g,b,a = StreetNames.ColorList[i] and StreetNames.ColorList[i] or Color(255,255,255,100)
                draw.SimpleText(streetname,"DermaDefault",0,ScrH() * .01 * i, StreetNames.ColorList[i])
            end
            i = i + 1
        end
    end
end)

function StreetNames:AdminPanel()
    local main = vgui.Create("DFrame")
    main:SetSize(ScrW() * .2, ScrH() * .4)
    main:MakePopup()
    main:Center()
    main:SetTitle("")
    main:ShowCloseButton(false)
    function main:Paint(w,h)
        surface.SetDrawColor(Color(31,31,31))
        surface.DrawRect(0,0,w,h)
    end

    local streetList = vgui.Create("DScrollPanel", main)

    streetList:SetSize(main:GetWide(), main:GetTall() * .8)
    streetList:SetPos(0,0)

    local sbar = streetList:GetVBar()
    function sbar:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0,0,w,h)
    end

    for streetname,routes in pairs(StreetNames.Streets) do

        local streetFrame = streetList:Add("DPanel")
        streetFrame:SetSize(streetList:GetWide(), streetList:GetTall() * .1)
        streetFrame:Dock(TOP)
        streetFrame:DockMargin(0,0,0,5)
        function streetFrame:Paint(w,h)
            surface.SetDrawColor(Color(51,51,51))
            surface.DrawRect(0,0,w,h)

            draw.SimpleText(streetname, "StreetNames.Main", w/2,h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local remove = vgui.Create("DButton", streetFrame)
        remove:SetText("X")
        remove:SetFont("StreetNames.Main")
        remove:SetSize(streetFrame:GetTall() * .8,streetFrame:GetTall() * .8)
        remove:SetColor(Color(255,255,255))
        remove:SetPos(streetFrame:GetWide() * .82, ( streetFrame:GetTall() / 2 ) - ( streetFrame:GetTall() * .8 / 2 ))
        function remove:Paint(w,h)
            surface.SetDrawColor(Color(100,0,0))
            surface.DrawRect(0,0,w,h)
        end

        function remove:DoClick()
            net.Start("StreetNames:DeleteStreet")
            net.WriteString(streetname)
            net.SendToServer()
            streetFrame:Remove()
        end

    end

    local close = vgui.Create("DButton", main)
    close:SetSize(main:GetWide() * .70, main:GetTall() * .1)
    close:SetPos(main:GetWide() * .15, main:GetTall() * .85)
    close:SetColor(Color(255,255,255))
    close:SetText("Close")
    close:SetFont("StreetNames.Main")
    function close:Paint(w,h)
        surface.SetDrawColor(Color(100,0,0))
        surface.DrawRect(0,0,w,h)
    end
    function close:DoClick()
        main:Remove()
    end
end

concommand.Add("streetnames_admin", function(ply)
    if not ply:IsSuperAdmin() then return chat.AddText(Color(255,255,255), "You cannot use this command!") end
    
    StreetNames:AdminPanel()
end)
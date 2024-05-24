local panel = CreateFrame("Frame")
panel.name = "Soulbind Cache Opener - Continued"               -- see panel fields
InterfaceOptions_AddCategory(panel)  -- see InterfaceOptions API

-- add widgets to the panel as desired
local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText("Soulbind Cache Opener - Continued")
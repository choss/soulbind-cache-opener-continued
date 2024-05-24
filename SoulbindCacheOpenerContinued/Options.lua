local _, L = ...;
function SoulbindCacheOpener:initializeOptions() 
    local panel = CreateFrame("Frame");
    panel.name = "Soulbind Cache Opener - Continued";            -- see panel fields
    InterfaceOptions_AddCategory(panel);  -- see InterfaceOptions API

    -- add widgets to the panel as desired
    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge");
    title:SetPoint("TOP");
    title:SetText("Soulbind Cache Opener - Continued");

    local headhiden = panel:CreateFontString("ARTWORK", nil, "GameFontNormal");
    headhiden:SetText("Hidden item groups");
    headhiden:SetPoint("TOPLEFT", 20, -30 );

    local i = 0;
    for name, items in pairs(SoulbindCacheOpener.groups) do
        local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate");
        cb:SetPoint("TOPLEFT", 20, -60 + (-30*i));
        cb.Text:SetText("   " .. L[name]);
        cb.group_id = name;
        local isChecked = false;
        if( SoulbindCacheOpenerDB.ignored_groups[name] ~= nil) then
            isChecked = SoulbindCacheOpenerDB.ignored_groups[name];
        end
        cb:SetChecked(isChecked);
        cb:HookScript("OnClick", function(_, btn, down)
		-- TODO: refactor that out, since it is also used in SoulbindCacheOpener:slashHandler() 
            SoulbindCacheOpenerDB.ignored_groups[name] = cb:GetChecked();
            SoulbindCacheOpener:updateIgnoreItems();
            SoulbindCacheOpener:updateButtons();
        end)
        i = i +1;
    end
end

local debug = false;

local _, L = ...;

function SoulbindCacheOpener:updateButtons()
	if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "4 - updateButtons Called") end end
	self.previous = 0;
	local freeSpace = 0;
	for containerIndex = 0, NUM_BAG_SLOTS do
		freeSlots = C_Container.GetContainerNumFreeSlots(containerIndex)
		freeSpace = freeSpace + freeSlots;
	end
	for i = 1, #self.items do
		if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "5 - self.items loop") end end
		self:updateButton(self.items[i].button,self.items[i],i,freeSpace);
	end
end

function SoulbindCacheOpener:updateButton(btn,currItem,num,freeSpace)
	local id = currItem.id;
	local count = GetItemCount(id);
--SoulbindCacheOpenerDB.rousing
	if (count >= currItem.minCount and not SoulbindCacheOpenerDB.ignored_items[id] ) then
		btn:ClearAllPoints();
		if SoulbindCacheOpenerDB.alignment == "LEFT" then
			if self.previous == 0 then
				btn:SetPoint("LEFT", self.frame, "LEFT", 0, 0);
			else
				btn:SetPoint("LEFT", self.items[self.previous].button, "RIGHT", 2, 0);
			end
		else
			if self.previous == 0 then
				btn:SetPoint("RIGHT", self.frame, "RIGHT", 0, 0);
			else
				btn:SetPoint("RIGHT", self.items[self.previous].button, "LEFT", -2, 0);
			end
		end
		if self.previous == 0 and SoulbindCacheOpenerDB.freeSpace then
			btn.freeSpaceFont:SetText("Free:"..freeSpace);
			btn.freeSpace:Show();
		else
			btn.freeSpaceFont:SetText("");
			btn.freeSpace:Hide();
		end
		self.previous = num;
		btn.countString:SetText(format("%d",count));
		btn.texture:SetDesaturated(false);
		if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "ButtonShow") end end
		btn:Show();
	else 
		btn.countString:SetText("");
		btn.freeSpaceFont:SetText("");
		btn.freeSpace:Hide();
		btn.texture:SetDesaturated(true);
		if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "ButtonHide") end end
		btn:Hide();
	end
end

function SoulbindCacheOpener:createButton(btn,id)
	if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "7 - createButton Called") end end
	btn:Hide();
	btn:SetWidth(38);
	btn:SetHeight(38);
	btn:SetClampedToScreen(true);
	--Right click to drag
	btn:EnableMouse(true);
	btn:RegisterForDrag("RightButton");
	btn:SetMovable(true);
	btn:SetScript("OnDragStart", function(self) self:GetParent():StartMoving(); end);
	btn:SetScript("OnDragStop", function(self) 
			self:GetParent():StopMovingOrSizing();
			self:GetParent():SetUserPlaced(false);
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint();
			SoulbindCacheOpenerDB.position = {point, nil, relativePoint, xOfs, yOfs};
			end);
	--Setup macro
	btn:SetAttribute("type", "macro");
	btn:SetAttribute("macrotext", format("/use item:%d",id));
	btn.countString = btn:CreateFontString(btn:GetName().."Count", "OVERLAY", "NumberFontNormal");
	btn.countString:SetPoint("BOTTOMRIGHT", btn, -0, 2);
	btn.countString:SetJustifyH("RIGHT");
	btn.freeSpace = CreateFrame("Frame", btn:GetName().."FreeSpace", btn);
	btn.freeSpace:SetFrameStrata("BACKGROUND");
	btn.freeSpace:SetWidth(35);
	btn.freeSpace:SetHeight(10);
	btn.freeSpace.t = btn.freeSpace:CreateTexture(nil, "BACKGROUND");
	btn.freeSpace.t:SetTexture(0,0,0,.8);
	btn.freeSpace.t:SetAllPoints(true);
	btn.freeSpace.texture = btn.freeSpace.t;
	btn.freeSpace:SetPoint("TOPLEFT", btn, 1.5, -1);
	btn.freeSpaceFont = btn.freeSpace:CreateFontString(btn.freeSpace:GetName().."Font", "OVERLAY", "SystemFont_Tiny");
	btn.freeSpaceFont:SetPoint("CENTER", btn.freeSpace, 0, 0);
	btn.freeSpaceFont:SetJustifyH("LEFT");
	btn.icon = btn:CreateTexture(nil,"BACKGROUND");
	btn.icon:SetTexture(GetItemIcon(id));
	btn.texture = btn.icon;
	btn.texture:SetAllPoints(btn);
	btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
	
	--Tooltip
	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self,"ANCHOR_TOP");
		GameTooltip:SetItemByID(format("%d",id));
		GameTooltip:SetClampedToScreen(true);
		GameTooltip:Show();
	  end);
	btn:SetScript("OnLeave",GameTooltip_Hide);
 end

function SoulbindCacheOpener:reset()
	if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "8 - Reset Called") end end
	SoulbindCacheOpenerDB = {["enable"] = true,["alignment"] = "LEFT",["freeSpace"] = false,["rousing"] = true, ["ignored_items"] = {}};
	self.frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0);
	self:OnEvent("UPDATE");
end

function SoulbindCacheOpener:AddButton()
	if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "2 - Add Button Called") end end
	self.frame:Show();
	if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "3 - Frame Shown") end end
	SoulbindCacheOpener:updateButtons();
end

function SoulbindCacheOpener:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "0 - Addon Loaded") end end
		self.frame:UnregisterEvent("ADDON_LOADED");
		SoulbindCacheOpenerDB = SoulbindCacheOpenerDB or {};
		--If DB is empty
		if next (SoulbindCacheOpenerDB) == nil then
			SoulbindCacheOpener:reset();
		end
		if SoulbindCacheOpenerDB.ignored_items == nil then
			SoulbindCacheOpenerDB.ignored_items = {};
		end
	end

	if event == "PLAYER_LOGIN" then
		if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "9 - Player Login Event") end end
		self.frame:UnregisterEvent("PLAYER_LOGIN");
	end 
	--Check for combat
	if UnitAffectingCombat("player") then
		if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "10 - Player is in Combat") end end
		return
	end
	if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "1 - Event Called") end end
	SoulbindCacheOpener:AddButton();
end

------------------------------------------------
-- Slash Commands
------------------------------------------------
local function slashHandler(msg)
	msg = msg:lower() or "";
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
--	if (msg == "free") then
--		SoulbindCacheOpenerDB.freeSpace = not SoulbindCacheOpenerDB.freeSpace;
--		SoulbindCacheOpener:updateButtons();
	--	if SoulbindCacheOpenerDB.freeSpace then
	--		print("|cffffa500Soulbind Cache Opener|r: Displaying inventory space text on button.");
	--	else
	--		print("|cffffa500Soulbind Cache Opener|r: Hiding inventory space text on button.");
	--	end

	if (cmd == "hide") then
		SoulbindCacheOpenerDB.ignored_items[tonumber(args)] = true;
		SoulbindCacheOpener:updateButtons();
		print ("|cffffa500Soulbind Cache Opener|r: ignoring itemid", args);


	elseif (cmd == "show") then
		SoulbindCacheOpenerDB.ignored_items[tonumber(args)] = false;
		SoulbindCacheOpener:updateButtons();
		print ("|cffffa500Soulbind Cache Opener|r: showing itemid", args);

	elseif (cmd == "hidegroup") then
		local groupIds = SoulbindCacheOpener.groups[args];
		if (groupIds ~= nil) then 
			for i, id in ipairs(groupIds) do
				SoulbindCacheOpenerDB.ignored_items[id] = true;
			end
		end
		SoulbindCacheOpener:updateButtons();
		print ("|cffffa500Soulbind Cache Opener|r: showing group", args);

	elseif (cmd == "showgroup") then
		local groupIds = SoulbindCacheOpener.groups[args];
		if (groupIds ~= nil) then 
			for i, id in ipairs(groupIds) do
				SoulbindCacheOpenerDB.ignored_items[id] = false;
			end
		end
		SoulbindCacheOpener:updateButtons();
		print ("|cffffa500Soulbind Cache Opener|r: showing group", args);

	elseif (msg == "reset") then
		print("|cffffa500Soulbind Cache Opener|r: Resetting settings and position.");
		SoulbindCacheOpener:reset();
	else
		print("|cffffa500Soulbind Cache Opener|r: Commands for |cffffa500/SoulbindCacheOpener|r :");
	--	print("  |cffffa500 free|r - Toggle text on button for remaining inventory space.");
		print("  |cffffa500 ignore <itemid>|r - Ignore stacks of an item");
		print("  |cffffa500 unignore <itemid>|r - Show stacks of an item");
		print("  |cffffa500 reset|r - Reset all settings!");
	end
end

SlashCmdList.SoulbindCacheOpener = function(msg) slashHandler(msg) end;
SLASH_SoulbindCacheOpener1 = "/SoulbindCacheOpener";
SLASH_SoulbindCacheOpener2 = "/SCO";

--Helper functions
local function cout(msg, premsg)
	premsg = premsg or "[".."Soulbind Cache Opener".."]"
	print("|cFFE8A317"..premsg.."|r "..msg);
end

local function coutBool(msg,bool)
	if bool then
		print(msg..": true");
	else
		print(msg..": false");
	end
end

--Main Frame
SoulbindCacheOpener.frame = CreateFrame("Frame", "SoulbindCacheOpener_Frame", UIParent);
SoulbindCacheOpener.frame:Hide();
SoulbindCacheOpener.frame:SetWidth(120);
SoulbindCacheOpener.frame:SetHeight(38);
SoulbindCacheOpener.frame:SetClampedToScreen(true);
SoulbindCacheOpener.frame:SetFrameStrata("BACKGROUND");
SoulbindCacheOpener.frame:SetMovable(true);
SoulbindCacheOpener.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
SoulbindCacheOpener.frame:RegisterEvent("PLAYER_REGEN_ENABLED");
SoulbindCacheOpener.frame:RegisterEvent("PLAYER_LOGIN");
SoulbindCacheOpener.frame:RegisterEvent("ADDON_LOADED")
SoulbindCacheOpener.frame:RegisterEvent("BAG_UPDATE");

SoulbindCacheOpener.frame:SetScript("OnEvent", function(self,event,...) SoulbindCacheOpener:OnEvent(event,...) end);
SoulbindCacheOpener.frame:SetScript("OnShow", function(self,event,...) 
	--Restore position
	self:ClearAllPoints();
	if SoulbindCacheOpenerDB and SoulbindCacheOpenerDB.position then
		self:SetPoint(SoulbindCacheOpenerDB.position[1],UIParent,SoulbindCacheOpenerDB.position[3],SoulbindCacheOpenerDB.position[4],SoulbindCacheOpenerDB.position[5]);
	else
		self:SetPoint('CENTER', UIParent, 'CENTER', 0, 0);
	end		
	
 end);
---Create button for each item
for i = 1, #SoulbindCacheOpener.items do
	SoulbindCacheOpener.items[i].button = CreateFrame("Button", SoulbindCacheOpener.items[i].name, SoulbindCacheOpener.frame, "SecureActionButtonTemplate");
	SoulbindCacheOpener:createButton(SoulbindCacheOpener.items[i].button,SoulbindCacheOpener.items[i].id);
end
if WOW_PROJECT_ID ~= (WOW_PROJECT_MAINLINE or 1) then -- Added in BfA
	return
end
local mod	= DBM:NewMod("z1191", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA"
)

mod:AddBoolOption("AutoTurnIn")

do
	local bgzone = false

	local function Init(self)
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and zoneID == 1191 then
			bgzone = true
			self:RegisterShortTermEvents(
				"GOSSIP_SHOW",
				"QUEST_PROGRESS",
				"QUEST_COMPLETE"
			)
			if not self.tracker then
				local generalMod = DBM:GetModByName("PvPGeneral")
				self.tracker = generalMod:NewHealthTracker()
				self.tracker:TrackHealth(82876, "Tremblade", BLUE_FONT_COLOR)
				self.tracker:TrackHealth(81859, "Fangraal", BLUE_FONT_COLOR)
				self.tracker:TrackHealth(82877, "Volrath", RED_FONT_COLOR)
				self.tracker:TrackHealth(82201, "Kronus", RED_FONT_COLOR)
			end
		elseif bgzone and zoneID ~= 1191 then
			bgzone = false
			self:UnregisterShormTermEvents()
			if self.tracker then
				self.tracker:Cancel()
				self.tracker = nil
			end
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init, self)
	end
	mod.ZONE_CHANGED_NEW_AREA	= mod.LOADING_SCREEN_DISABLED
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end

do
	local UnitGUID, GetCurrencyInfo, GetNumGossipOptions = UnitGUID, C_CurrencyInfo.GetCurrencyInfo, C_GossipInfo.GetNumOptions

	function mod:GOSSIP_SHOW()
		if not self.Options.AutoTurnIn then
			return
		end
		local cid = self:GetCIDFromGUID(UnitGUID("target") or "")
		if cid == 81870 or cid == 82204 or cid == 183198 then -- Anenga (Alliance) | Atomik/Narduke (Horde)
			local _, currency = GetCurrencyInfo(944) -- Artifact Fragment
			if currency > 0 and GetNumGossipOptions() == 3 then -- If boss isn't already summoned
				local gossipOptionID = self:GetGossipID()
				if gossipOptionID then
					self:SelectGossip(gossipOptionID)
				end
			end
		end
	end
end

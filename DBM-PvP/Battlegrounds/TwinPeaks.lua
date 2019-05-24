﻿-- Twin Peaks mod v1.0
--
-- Thanks to Samira (EU-Thrall)


local mod		= DBM:NewMod("z726", "DBM-PvP", 2)
local L			= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

local bgzone = false

--local startTimer		= mod:NewTimer(62, "TimerStart", 2457)
local flagTimer			= mod:NewTimer(12, "TimerFlag", "Interface\\Icons\\INV_Banner_02")
local vulnerableTimer	= mod:NewNextTimer(60, 46392)

do
	local function TwinPeaks_Initialize(self)
		if DBM:GetCurrentArea() == 726 then
			bgzone = true
			self:RegisterShortTermEvents(
				"CHAT_MSG_BG_SYSTEM_ALLIANCE",
				"CHAT_MSG_BG_SYSTEM_HORDE",
				"CHAT_MSG_BG_SYSTEM_NEUTRAL",
				"CHAT_MSG_RAID_BOSS_EMOTE"
			)

		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
		end
	end
	mod.OnInitialize = TwinPeaks_Initialize

	function mod:ZONE_CHANGED_NEW_AREA()
		self:Schedule(1, TwinPeaks_Initialize, self)
	end
end

function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
	if msg == L.Vulnerable1 or msg == L.Vulnerable2 or msg:find(L.Vulnerable1) or msg:find(L.Vulnerable2) then
		vulnerableTimer:Start()
	end
end

do
	local function updateflagcarrier(self, event, arg1)
		if string.match(arg1, L.ExprFlagCaptured) then
			flagTimer:Start()
			vulnerableTimer:Cancel()
		end
	end
	function mod:CHAT_MSG_BG_SYSTEM_ALLIANCE(...)
		updateflagcarrier(self, "CHAT_MSG_BG_SYSTEM_ALLIANCE", ...)
	end
	function mod:CHAT_MSG_BG_SYSTEM_HORDE(...)
		updateflagcarrier(self, "CHAT_MSG_BG_SYSTEM_HORDE", ...)
	end
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(...)
		updateflagcarrier(self, "CHAT_MSG_RAID_BOSS_EMOTE", ...)
	end
end

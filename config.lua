Config = {}

Config.ChatColor = { 255, 255, 0 } -- This is the yellow color

Config.RequireHealReason = true
Config.RequireReviveReason = true

Config.AllowedGroups = {
    "admin",
    "superadmin",
    "mod"
}

Config.UseAce = false 
Config.AcePermission = "heallog.view"

Config.EnableTxAdminHealHook = true

Config.HealCommand = "heal"
Config.ReviveCommand = "revive"
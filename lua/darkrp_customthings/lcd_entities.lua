AddCSLuaFile()

if LCD.Config.AddEntites == false then return end


DarkRP.createCategory{
	name = "LCD Printers",
	categorises = "entities",
	startExpanded = true,
	color = Color(0, 180, 0, 255),
}


DarkRP.createEntity("Money Printer", {
		ent = "lcd_printer",
		model = "models/props_c17/consolebox01a.mdl",
		price = 1000,
		max = 5,
		cmd = "buylcdprinter",
		category = "LCD Printers"
})


DarkRP.createEntity("Printer Coolant (" .. LCD.Config.CoolantAdded .. "l)", {
		ent = "lcd_coolant",
		model = "models/Items/battery.mdl",
		price = 100,
		max = 5,
		cmd = "buylcdcoolant",
		category = "LCD Printers"
})

DarkRP.createEntity("Overclocker Upgrade", {
		ent = "lcd_overclocker",
		model = "models/props_lab/reciever01a.mdl",
		price = 2000,
		max = 5,
		cmd = "buylcdoverclocker",
		category = "LCD Printers"
})

DarkRP.createEntity("Fan Upgrade", {
		ent = "lcd_fan",
		model = "models/props_lab/reciever01a.mdl",
		price = 750,
		max = 5,
		cmd = "buylcdfan",
		category = "LCD Printers"
})

DarkRP.createEntity("Screen Upgrade", {
		ent = "lcd_screen",
		model = "models/props_lab/reciever01a.mdl",
		price = 250,
		max = 5,
		cmd = "buylcdscreen",
		category = "LCD Printers"
})

DarkRP.createEntity("Storage Upgrade", {
		ent = "lcd_storage",
		model = "models/props_lab/reciever01a.mdl",
		price = 500,
		max = 5,
		cmd = "buylcdstorage",
		category = "LCD Printers"
})

DarkRP.createEntity("Armor Upgrade", {
		ent = "lcd_armor",
		model = "models/props_lab/reciever01a.mdl",
		price = 500,
		max = 5,
		cmd = "buylcdarmor",
		category = "LCD Printers"
})
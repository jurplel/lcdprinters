--[[---------------------------------------------------------------------------
This is an example of a custom entity.
---------------------------------------------------------------------------]]
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.SeizeReward = LCD.Config.SeizeReward

local PreMoney

local PrinterStoredMoney = LCD.Config.StartingStoredMoney

local PrinterTemperature = LCD.Config.StartingTemperature

local PrinterExplosion = 0

local PrinterCoolant = LCD.Config.StartingCoolant

local PrinterFan = LCD.Config.StartingFan

local PrinterScreen = LCD.Config.StartingScreen

local PrinterStorage = LCD.Config.StartingStorage

local PrinterArmor = LCD.Config.StartingArmor

local PrinterMode = 0

function ENT:Initialize()

	PrinterStoredMoney = LCD.Config.StartingStoredMoney
	self:SetNWInt( "StoredMoney", PrinterStoredMoney )

	PrinterTemperature = LCD.Config.StartingTemperature
	self:SetNWInt( "StoredTemp", PrinterTemperature )

	PrinterExplosion = 0
	self:SetNWInt( "StoredExpl", PrinterExplosion )

	PrinterCoolant = LCD.Config.StartingCoolant
	self:SetNWInt( "StoredCool", PrinterCoolant )

	PrinterFan = LCD.Config.StartingFan
	self:SetNWBool( "StoredFan", PrinterFan )

	PrinterScreen = LCD.Config.StartingScreen
	self:SetNWBool( "StoredScreen", PrinterScreen )

	PrinterStorage = LCD.Config.StartingStorage
	self:SetNWBool( "StoredStorage", PrinterStorage )

	PrinterArmor = LCD.Config.StartingArmor
	self:SetNWBool( "StoredArmor", PrinterArmor )

	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()

	self.sparking = false
	if PrinterArmor == false then
		self.damage = LCD.Config.HitPoints
	else
		self.damage = LCD.Config.ArmorHitPoints
	end
	self.IsMoneyPrinter = true

	timer.Create( "PrinterCountdown1", math.random(LCD.Config.PrintTimer1,LCD.Config.PrintTimer2), 1, function() PreMoney(self) end)

	self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
	self.sound:SetSoundLevel(52)
	self.sound:PlayEx(1, 100)
end

function ENT:OnTakeDamage(dmg)
	if self.burningup then return end

	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		local rnd = math.random(1, 10)
		if rnd < 3 then
			self:BurstIntoFlames()
		else
			self:Destruct()
			self:Remove()
		end
	end
end

-- the explosion stuff

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	DarkRP.notify(self:Getowning_ent(), 1, 4, DarkRP.getPhrase("money_printer_exploded"))
end

function ENT:BurstIntoFlames()
	DarkRP.notify(self:Getowning_ent(), 0, 4, DarkRP.getPhrase("money_printer_overheating"))
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, function()
	if not IsValid(self) then return end
	self:Fireball() 
	end)
end

function ENT:Fireball()
	if not self:IsOnFire() then self.burningup = false return end
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v:IsWeapon() and v:GetClass() ~= "predicted_viewmodel" and not v.IsMoneyPrinter then
			v:Ignite(math.random(5, 22), 0)
		elseif v:IsPlayer() then
			local distance = v:GetPos():Distance(self:GetPos())
			v:TakeDamage(distance / dist * 100, self, self)
		end
	end
	self:Remove()
end

function ENT:TestExplosion()
	if not IsValid(self) or self:IsOnFire() then return end
	local explchance = math.random(1,100)
	if explchance <= PrinterExplosion then
		self:BurstIntoFlames()
	else
		DarkRP.notify(self:Getowning_ent(), 0, 4, "Your printer is in danger of exploding!")
	end
end

-- the money stuff

PreMoney = function(ent)
	if not IsValid(ent) then return end

	ent.sparking = true
	ent:EmitSound("buttons/button6.wav")
	timer.Simple(3, function()
		if not IsValid(ent) then return end
		ent:AddMoney()
	end)
end

function ENT:AddMoney()
	if not IsValid(self) or self:IsOnFire() then return end

	if PrinterExplosion > 0 then
		self:TestExplosion()
	end
	local effectivestorage
	if PrinterStorage == true then
		effectivestorage = LCD.Config.UpgradeMaximum
	else
		effectivestorage = LCD.Config.PrintMaximum
	end
	if PrinterStoredMoney < effectivestorage then
		if PrinterMode == 1 then
			PrinterStoredMoney = PrinterStoredMoney + math.random(LCD.Config.OverclockerPrintAmount1, LCD.Config.OverclockerPrintAmount2)
		else
			PrinterStoredMoney = PrinterStoredMoney + math.random(LCD.Config.PrintAmount1, LCD.Config.PrintAmount2)
		end
		self:SetNWInt( "StoredMoney", PrinterStoredMoney )

		self:EmitSound("buttons/button4.wav")
		if PrinterMode == 1 then
			if PrinterFan == false then
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.OverclockerHeatNoFan1, LCD.Config.OverclockerHeatNoFan2)
			else
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.OverclockerHeatFan1, LCD.Config.OverclockerHeatFan2)
			end
		else
			if PrinterFan == false then
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.HeatNoFan1, LCD.Config.HeatNoFan2)
			else
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.HeatFan1, LCD.Config.HeatFan2)
			end
		end
		self:SetNWInt( "StoredTemp", PrinterTemperature )

	else
		self:EmitSound("buttons/button8.wav")
		DarkRP.notify(self:Getowning_ent(), 0, 4, "Your money printer is full!")
		if PrinterFan == false then
			PrinterTemperature = PrinterTemperature + math.random(LCD.Config.HeatNoFanFull1, LCD.Config.HeatNoFanFull2)
		else
			PrinterTemperature = PrinterTemperature + math.random(LCD.Config.HeatFanFull1, LCD.Config.HeatFanFull2)
		end
		self:SetNWInt( "StoredTemp", PrinterTemperature )
	end
	self.sparking = false
	if PrinterMode == 1 then
		timer.Create( "PrinterCountdown2", math.random(LCD.Config.PrintTimer1,LCD.Config.PrintTimer2), 1, function() PreMoney(self) end)
	else
		timer.Create( "PrinterCountdown2", math.random(LCD.Config.OverclockerPrintTimer1,LCD.Config.OverclockerPrintTimer2), 1, function() PreMoney(self) end)
	end
end

function ENT:CreateMoneybag( ply )
	if not IsValid(self) or self:IsOnFire() then return end

	local MoneyPos = self:GetPos()

	ply:addMoney(PrinterStoredMoney)
	DarkRP.notify(ply, 0, 4, "Withdrew $" .. PrinterStoredMoney)
	PrinterStoredMoney = 0
	self:SetNWInt( "StoredMoney", PrinterStoredMoney )
	self:EmitSound("ambient/tones/equip3.wav")
end

-- the misc stuff

function ENT:CoolOff()
	if PrinterCoolant > 0 and PrinterTemperature > LCD.Config.CoolingMinTemperature then

		PrinterCoolant = PrinterCoolant - LCD.Config.CoolingCoolant
		self:SetNWInt( "StoredCool", PrinterCoolant )

		PrinterTemperature = PrinterTemperature - LCD.Config.CoolingTemp
		self:SetNWInt( "StoredTemp", PrinterTemperature )
	end

end

function ENT:Use( ply )
	if PrinterStoredMoney > 0 then
		self:CreateMoneybag( ply )
	end
end

function ENT:Think()

	self:CoolOff()

	local TempIncreaseChance = math.random(1,100)
	if PrintMode == 1 then
		if PrinterFan == false then
			if TempIncreaseChance > LCD.Config.HeatChanceNoFan then
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.OverclockerHeatAddedFan1, LCD.Config.OverclockerHeatAddedFan2)
				self:SetNWInt( "StoredTemp", PrinterTemperature )
			end
		else
			if TempIncreaseChance > LCD.Config.HeatChanceFan then
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.OverclockerHeatAddedNoFan1, LCD.Config.OverclockerHeatAddedNoFan2)
				self:SetNWInt( "StoredTemp", PrinterTemperature )
			end
		end
	else
		if PrinterFan == false then
			if TempIncreaseChance > LCD.Config.HeatChanceNoFan then
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.HeatAddedFan1, LCD.Config.HeatAddedFan2)
				self:SetNWInt( "StoredTemp", PrinterTemperature )
			end
		else
			if TempIncreaseChance > LCD.Config.HeatChanceFan then
				PrinterTemperature = PrinterTemperature + math.random(LCD.Config.HeatAddedNoFan1, LCD.Config.HeatAddedNoFan2)
				self:SetNWInt( "StoredTemp", PrinterTemperature )
			end
		end
	end

	if PrinterTemperature >= 65 then
		PrinterExplosion = math.floor(((PrinterTemperature-65)/3.5)^2)
		self:SetNWInt( "StoredExpl", PrinterExplosion )
	else
		PrinterExplosion = 0
		self:SetNWInt( "StoredExpl", PrinterExplosion )
	end

	if self:WaterLevel() > 0 then
		self:Destruct()
		self:Remove()
		return
	end

	if (timer.Exists( "PrinterCountdown1" )) then
		local count1 = math.floor(timer.TimeLeft( "PrinterCountdown1" ))
		if count1 <= 9999 then
			self:SetNWInt( "StoredCount", count1 )
		else
			self:SetNWInt( "StoredCount", 0 )
		end
	else
		local count2 = math.floor(timer.TimeLeft( "PrinterCountdown2" ))
		if count2 <= 9999 then
			self:SetNWInt( "StoredCount", count2 )
		else
			self:SetNWInt( "StoredCount", 0 )
		end
	end

	if not self.sparking then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end

function ENT:PhysicsCollide(data, phys)

	if PrinterFan == false then
		if (data.HitEntity:GetClass() == "lcd_fan") then
			data.HitEntity:Remove()

			PrinterFan = true
			self:SetNWBool( "StoredFan", PrinterFan )

			self:EmitSound("buttons/lever8.wav")
			self.soundfan = CreateSound(self, Sound("ambient/tones/fan2_loop.wav"))
			self.soundfan:SetSoundLevel(52)
			self.soundfan:PlayEx(1, 100)
		end
	end
	
	if PrinterScreen == false then
		if (data.HitEntity:GetClass() == "lcd_screen") then
			data.HitEntity:Remove()

			PrinterScreen = true
			self:SetNWBool( "StoredScreen", PrinterScreen )

			self:EmitSound("buttons/lever8.wav")
		end
	end

	if PrinterStorage == false then
		if (data.HitEntity:GetClass() == "lcd_storage") then
			data.HitEntity:Remove()

			PrinterStorage = true
			self:SetNWBool( "StoredStorage", PrinterStorage )

			self:EmitSound("buttons/lever8.wav")
		end
	end

	if PrinterArmor == false then
		if (data.HitEntity:GetClass() == "lcd_armor") then
			data.HitEntity:Remove()

			PrinterArmor = true
			self:SetNWBool( "StoredArmor", PrinterArmor )

			self:EmitSound("buttons/lever8.wav")
			
			self.damage = LCD.Config.ArmorHitPoints
		end
	end

	if (data.HitEntity:GetClass() == "lcd_coolant") and PrinterCoolant <= LCD.Config.CoolantAdded then
		data.HitEntity:Remove()

		PrinterCoolant = PrinterCoolant + LCD.Config.CoolantAdded
		self:SetNWInt( "StoredCool", PrinterCoolant )
	elseif (data.HitEntity:GetClass() == "lcd_coolant") and PrinterCoolant > 20 - LCD.Config.CoolantAdded and PrinterCoolant < 20 then
		data.HitEntity:Remove()

		PrinterCoolant = PrinterCoolant + (20 - PrinterCoolant)
		self:SetNWInt( "StoredCool", PrinterCoolant )
	end

	if PrinterMode == 0 then
		if (data.HitEntity:GetClass() == "lcd_overclocker") then
			data.HitEntity:Remove()

			PrinterMode = 1
			self:SetNWInt( "StoredMode", PrinterMode )

			self:EmitSound("buttons/lever8.wav")
		end
	end

end
function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
	if self.soundfan then
		self.soundfan:Stop()
	end
end

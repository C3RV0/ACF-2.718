--[[
	Clientside effect positioning for ACF rounds
	A few extra comments for better readability. Nothing else really needs changing.
]]--

ACF.BulletEffect = {}

function ACF_ManageBulletEffects()
	
	for Index,Bullet in pairs(ACF.BulletEffect) do
		ACF_SimBulletFlight( Bullet, Index )	-- This is the bullet entry in the table, the omnipresent Index var refers to this
	end
	
end
hook.Add("Think", "ACF_ManageBulletEffects", ACF_ManageBulletEffects)

function ACF_SimBulletFlight( Bullet, Index )

	-- Compares the current time against the last time the bullet updated
	local DeltaTime = CurTime() - Bullet.LastThink
	
	-- Gets the velocity, normalizes it and calculates the drag
	local Drag = Bullet.SimFlight:GetNormalized() * (Bullet.DragCoef * Bullet.SimFlight:Length() ^ 2) / ACF.DragDiv
	
	Bullet.SimPosLast = Bullet.SimPos	-- Gets the current position of the bullet
	
	Bullet.SimPos = Bullet.SimPos + (Bullet.SimFlight * ACF.VelScale * DeltaTime)	-- Calculates the new position of the bullet
	
	Bullet.SimFlight = Bullet.SimFlight + (Bullet.Accel - Drag) * DeltaTime		-- Calculates the new velocity of the bullet
	
	if Bullet and Bullet.Effect:IsValid() then
		Bullet.Effect:ApplyMovement( Bullet )
	end
	
	Bullet.LastThink = CurTime()	-- Sets the "last updated" time of the bullet to the current time
	
end

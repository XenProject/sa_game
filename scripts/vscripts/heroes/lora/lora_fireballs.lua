function FireBallsStart( event )
	local caster = event.caster
	local ability = event.ability
	local playerID = caster:GetPlayerID()
	local radius = ability:GetSpecialValueFor("radius" )
	local duration = ability:GetSpecialValueFor("duration")
	local fireballs_num = ability:GetSpecialValueFor("fireballs_num")
	local delay_between_fireballs = ability:GetSpecialValueFor("delay_between_fireballs")
	local unit_name = "npc_dummy_unit"

	-- Initialize the table to keep track of all spirits
	ability.fireballs = {}
	print("Spawning "..fireballs_num.." spirits")
	for i=1,fireballs_num do
		Timers:CreateTimer(i * delay_between_fireballs, function()
			local unit = CreateUnitByName(unit_name, caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())

			-- The modifier takes care of the physics and logic
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_fireball", {})
			
			-- Add the spawned unit to the table
			table.insert(ability.fireballs, unit)

			-- Initialize the number of hits, to define the heal done after the ability ends
			unit.numberOfHits = 0

			-- Double check to kill the units, remove this later
			Timers:CreateTimer(duration+1, function() if unit and IsValidEntity(unit) then unit:RemoveSelf() end end)
		end)
	end
end

function FireBallsPhysics( event )
	local caster = event.caster
	local unit = event.target
	local ability = event.ability
	local radius = ability:GetSpecialValueFor( "radius" )
	local duration = ability:GetSpecialValueFor( "duration" )
	local fireball_speed = ability:GetSpecialValueFor( "fireball_speed" )
	local give_up_distance = ability:GetSpecialValueFor( "max_distance" )
	local max_distance = ability:GetSpecialValueFor( "max_distance" )
	local min_time_between_attacks = ability:GetSpecialValueFor( "min_time_between_attacks" )
	local abilityDamageType = ability:GetAbilityDamageType()
	local abilityTargetType = ability:GetAbilityTargetType()

	-- Make the spirit a physics unit
	Physics:Unit(unit)

	-- General properties
	unit:PreventDI(true)
	unit:SetAutoUnstuck(false)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	unit:FollowNavMesh(false)
	unit:SetPhysicsVelocityMax(fireball_speed)
	unit:SetPhysicsVelocity(fireball_speed * RandomVector(1))
	unit:SetPhysicsFriction(0)
	unit:Hibernate(false)
	unit:SetGroundBehavior(PHYSICS_GROUND_LOCK)

	-- Initial default state
	unit.state = "acquiring"

	-- This is to skip frames
	local frameCount = 0

	-- Store the damage done
	unit.damage_done = 0

	-- Store the interval between attacks, starting at min_time_between_attacks
	unit.last_attack_time = GameRules:GetGameTime() - min_time_between_attacks

	-- Color Debugging for points and paths. Turn it false later!
	local Debug = false
	local pathColor = Vector(255,255,255) -- White to draw path
	local targetColor = Vector(255,0,0) -- Red for enemy targets
	local idleColor = Vector(0,255,0) -- Green for moving to idling points
	local returnColor = Vector(0,0,255) -- Blue for the return
	local endColor = Vector(0,0,0) -- Back when returning to the caster to end
	local draw_duration = 3

	-- Find one target point at random which will be used for the first acquisition.
	local point = caster:GetAbsOrigin() + RandomVector(RandomInt(radius/2, radius))
	point.z = GetGroundHeight(point,nil)

	-- This is set to repeat on each frame
	unit:OnPhysicsFrame(function(unit)
		-- Move the unit orientation to adjust the particle
		unit:SetForwardVector( ( unit:GetPhysicsVelocity() ):Normalized() )

		-- Current positions
		local source = caster:GetAbsOrigin()
		local current_position = unit:GetAbsOrigin()

		-- Print the path on Debug mode
		if Debug then DebugDrawCircle(current_position, pathColor, 0, 2, true, draw_duration) end

		local enemies = nil

		-- Use this if skipping frames is needed (--if frameCount == 0 then..)
		frameCount = (frameCount + 1) % 3

		-- Movement and Collision detection are state independent

		-- MOVEMENT	
		-- Get the direction
		local diff = point - unit:GetAbsOrigin()
        diff.z = 0
        local direction = diff:Normalized()

		-- Calculate the angle difference
		local angle_difference = RotationDelta(VectorToAngles(unit:GetPhysicsVelocity():Normalized()), VectorToAngles(direction)).y
		
		-- Set the new velocity
		if math.abs(angle_difference) < 5 then
			-- CLAMP
			local newVel = unit:GetPhysicsVelocity():Length() * direction
			unit:SetPhysicsVelocity(newVel)
		elseif angle_difference > 0 then
			local newVel = RotatePosition(Vector(0,0,0), QAngle(0,10,0), unit:GetPhysicsVelocity())
			unit:SetPhysicsVelocity(newVel)
		else		
			local newVel = RotatePosition(Vector(0,0,0), QAngle(0,-10,0), unit:GetPhysicsVelocity())
			unit:SetPhysicsVelocity(newVel)
		end

		-- COLLISION CHECK
		local distance = (point - current_position):Length()
		local collision = distance < 300

		-- MAX DISTANCE CHECK
		local distance_to_caster = (source - current_position):Length()
		if distance > max_distance then 
			unit:SetAbsOrigin(source)
			unit.state = "acquiring" 
		end

		-- STATE DEPENDENT LOGIC
		-- Damage, Healing and Targeting are state dependent.
		-- Update the point in all frames

		-- Acquiring...
		-- Acquiring -> Target Acquired (enemy or idle point)
		-- Target Acquired... if collision -> Acquiring or Return
		-- Return... if collision -> Acquiring

		-- Acquiring finds new targets and changes state to target_acquired with a current_target if it finds enemies or nil and a random point if there are no enemies
		if unit.state == "acquiring" then

			-- This is to prevent attacking the same target very fast
			local time_between_last_attack = GameRules:GetGameTime() - unit.last_attack_time
			--print("Time Between Last Attack: "..time_between_last_attack)

			-- If enough time has passed since the last attack, attempt to acquire an enemy
			if time_between_last_attack >= min_time_between_attacks then
				-- If the unit doesn't have a target locked, find enemies near the caster
				enemies = FindUnitsInRadius(caster:GetTeamNumber(), source, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
											  abilityTargetType, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				-- Check the possible enemies
				-- Focus the last attacked target if there's any
				local last_targeted = ability.last_targeted
				local target_enemy = nil
				for _,enemy in pairs(enemies) do

					-- If the caster has a last_targeted and this is in range of the ghost acquisition, set to attack it
					if last_targeted and enemy == last_targeted then
						target_enemy = enemy
					end
				end

				-- Else if we don't have a target_enemy from the last_targeted, get one at random
				if not target_enemy then
					target_enemy = enemies[RandomInt(1, #enemies)]
				end
				
				-- Keep track of it, set the state to target_acquired
				if target_enemy then
					unit.state = "target_acquired"
					unit.current_target = target_enemy
					point = unit.current_target:GetAbsOrigin()
					print("Acquiring -> Enemy Target acquired: "..unit.current_target:GetUnitName())

				-- If no enemies, set the unit to collide with a random idle point.
				else
					unit.state = "target_acquired"
					unit.current_target = nil
					unit.idling = true
					point = source + RandomVector(RandomInt(radius/2, radius))
					point.z = GetGroundHeight(point,nil)
					
					--print("Acquiring -> Random Point Target acquired")
					if Debug then DebugDrawCircle(point, idleColor, 100, 25, true, draw_duration) end
				end

			-- not enough time since the last attack, get a random point
			else
				unit.state = "target_acquired"
				unit.current_target = nil
				unit.idling = true
				point = source + RandomVector(RandomInt(radius/2, radius))
				point.z = GetGroundHeight(point,nil)
				
				print("Waiting for attack time. Acquiring -> Random Point Target acquired")
				if Debug then DebugDrawCircle(point, idleColor, 100, 25, true, draw_duration) end
			end

		-- If the state was to follow a target enemy, it means the unit can perform an attack. 		
		elseif unit.state == "target_acquired" then

			-- Update the point of the target's current position
			if unit.current_target then
				point = unit.current_target:GetAbsOrigin()
				if Debug then DebugDrawCircle(point, targetColor, 100, 25, true, draw_duration) end
			end

			-- Give up on the target if the distance goes over the give_up_distance
			if distance_to_caster > give_up_distance then
				unit.state = "acquiring"
				--print("Gave up on the target, acquiring a new target.")

			end

			-- Do physical damage here, and increase hit counter. 
			if collision then

				-- If the target was an enemy and not a point, the unit collided with it
				if unit.current_target ~= nil then					
					-- Damage, units will still try to collide with attack immune targets but the damage wont be applied
					if not unit.current_target:IsAttackImmune() then
						local projectile_speed = 1400
						local particle_name = "particles/heroes/lora/fireball_laser.vpcf"

						-- Create the projectile
					    local info = {
					        Target = unit.current_target,
					        Source = unit,
					        Ability = ability,
					        EffectName = particle_name,
					        bDodgeable = false,
					        bProvidesVision = true,
					        iMoveSpeed = projectile_speed,
					        iVisionRadius = 0,
					        iVisionTeamNumber = caster:GetTeamNumber(),
					        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
					    }
					    ProjectileManager:CreateTrackingProjectile( info )

						local damage_table = {}

						local fireball_damage = ability:GetSpecialValueFor("damage") / 2
						damage_table.victim = unit.current_target
						damage_table.attacker = caster					
						damage_table.damage_type = abilityDamageType
						damage_table.damage = fireball_damage

						ApplyDamage(damage_table)

						--[[ Calculate how much physical damage was dealt
						local targetArmor = unit.current_target:GetPhysicalArmorValue()
						local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
						local damagePostReduction = spirit_damage * (1 - damageReduction)

						unit.damage_done = unit.damage_done + damagePostReduction

						-- Damage particle, different for buildings
						if unit.current_target.InvulCount == 0 then
							local particle = ParticleManager:CreateParticle(particleDamageBuilding, PATTACH_ABSORIGIN, unit.current_target)
							ParticleManager:SetParticleControl(particle, 0, unit.current_target:GetAbsOrigin())
							ParticleManager:SetParticleControlEnt(particle, 1, unit.current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", unit.current_target:GetAbsOrigin(), true)
						elseif unit.damage_done > 0 then
							local particle = ParticleManager:CreateParticle(particleDamage, PATTACH_ABSORIGIN, unit.current_target)
							ParticleManager:SetParticleControl(particle, 0, unit.current_target:GetAbsOrigin())
							ParticleManager:SetParticleControlEnt(particle, 1, unit.current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", unit.current_target:GetAbsOrigin(), true)
						end]]

						-- Increase the numberOfHits for this unit
						unit.numberOfHits = unit.numberOfHits + 1 

						-- Fire Sound on the target unit
						--unit.current_target:EmitSound("Hero_DeathProphet.Exorcism.Damage")
						
						-- Set to return
						unit.state = "returning"
						point = source
						--print("Returning to caster after dealing ",unit.damage_done)

						-- Update the attack time of the unit.
						unit.last_attack_time = GameRules:GetGameTime()
						--unit.enemy_collision = true

					end

				-- In other case, its a point, reacquire target or return to the caster (50/50)
				else
					if RollPercentage(50) then
						unit.state = "acquiring"
						--print("Attempting to acquire a new target")
					else
						unit.state = "returning"
						point = source
						--print("Returning to caster after idling")
					end
				end
			end

		-- If it was a collision on a return (meaning it reached the caster), change to acquiring so it finds a new target
		elseif unit.state == "returning" then
			
			-- Update the point to the caster's current position
			point = source
			if Debug then DebugDrawCircle(point, returnColor, 100, 25, true, draw_duration) end

			if collision then 
				unit.state = "acquiring"
			end	

		-- if set the state to end, the point is also the caster position, but the units will be removed on collision
		elseif unit.state == "end" then
			point = source
			if Debug then DebugDrawCircle(point, endColor, 100, 25, true, 2) end

			-- Last collision ends the unit
			if collision then 

				-- Heal is calculated as: a percentage of the units average attack damage multiplied by the amount of attacks the spirit did.
				--print("Healed ",heal_done)

				unit:SetPhysicsVelocity(Vector(0,0,0))
	        	unit:OnPhysicsFrame(nil)
	        	unit:ForceKill(false)

	        end
	    end
    end)
end

function FireBallsEnd( event )
	local caster = event.caster
	local ability = event.ability
	local targets = ability.fireballs

	print("Exorcism End")
	for _,unit in pairs(targets) do		
	   	if unit and IsValidEntity(unit) then
    	  	unit.state = "end"
    	end
	end

	-- Reset the last_targeted
	ability.last_targeted = nil
end

-- Kill all units when the owner dies or the spell is cast while the first one is still going
function FireBallsDeath( event )
	local caster = event.caster
	local ability = event.ability
	local targets = ability.spirits or {}

	print("Exorcism Death")
	for _,unit in pairs(targets) do		
	   	if unit and IsValidEntity(unit) then
    	  	unit:SetPhysicsVelocity(Vector(0,0,0))
	        unit:OnPhysicsFrame(nil)

			-- Kill
	        unit:ForceKill(false)
    	end
	end
end
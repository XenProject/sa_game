function Lightning( event )
	local maxBounces = event.ability:GetSpecialValueFor("maxBounces")
	local caster  = event.caster
	local target = event.target
	local source = caster
	local ability = event.ability
	local delay = 0.3
	local bounces = 0

	local targetsStruck = {}

	Timers:CreateTimer(
    	function()
    		if bounces < maxBounces then
				local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/ti7/maelstorm_ti7.vpcf", PATTACH_WORLDORIGIN, source)
				ParticleManager:SetParticleControl(nFXIndex, 0, Vector(source:GetAbsOrigin().x,source:GetAbsOrigin().y,source:GetAbsOrigin().z + source:GetBoundingMaxs().z ) )
				ParticleManager:SetParticleControl(nFXIndex, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ) )
				EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", target)

				local damageTable = {
					victim = target,
					attacker = caster,
					damage = ability:GetSpecialValueFor("lightning_damage") ,
					damage_type = DAMAGE_TYPE_PURE,
					ability = ability
				}
				ApplyDamage(damageTable)

				target.struckByChain = true
    			table.insert(targetsStruck,target)

				local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),
				nil, 400,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	        	local possibleTargets = {}

	        	source = target
	        	for _,enemy in pairs(targets) do
			        if enemy and not enemy.struckByChain then
			        	table.insert(possibleTargets,enemy)
			        end
			    end
	        	target = possibleTargets[math.random(1,#possibleTargets)]

	        	if target == nil then
	        		EndChain(targetsStruck)
	        		return
	        	end

				bounces = bounces + 1
				return delay
			else
      			EndChain(targetsStruck)
      			return
      		end
    	end
	)

	
end

function EndChain( targets )
	for _,v in pairs(targets) do
        v.struckByChain = false
        v = nil
    end
end
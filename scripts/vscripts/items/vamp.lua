LinkLuaModifier( "modifier_item_vamp", "items/modifier_item_vamp", LUA_MODIFIER_MOTION_NONE )

function OnEquipVampItem(event)
	Timers:CreateTimer(0.01, function()
		local caster = event.caster
		local vamp_prt = event.ability:GetSpecialValueFor("vamp_prt")
		local vamp_mod = caster:FindModifierByName("modifier_item_vamp")
		print(vamp_prt)
		if vamp_mod ~= nil then
			print("OLD - "..vamp_mod.vamp_prt)
			if vamp_mod.vamp_prt < vamp_prt then
				vamp_mod.vamp_prt = vamp_prt
			end
		else
			caster:AddNewModifier(caster, event.ability, "modifier_item_vamp", {vamp_prt = vamp_prt})
		end
	end)
end

function OnUnequipVampItem(event)
	local caster = event.caster
	local vamp_mod = caster:FindModifierByName("modifier_item_vamp")
	if caster:HasModifier("modifier_item_sa_bloodsword") then
		local ability = caster:FindModifierByName("modifier_item_sa_bloodsword"):GetAbility()
		local vamp_prt = ability:GetSpecialValueFor("vamp_prt")
		vamp_mod.vamp_prt = vamp_prt
	elseif caster:HasModifier("modifier_item_sa_bloodsabre") then
		local ability = caster:FindModifierByName("modifier_item_sa_bloodsabre"):GetAbility()
		local vamp_prt = ability:GetSpecialValueFor("vamp_prt")
		vamp_mod.vamp_prt = vamp_prt
	elseif caster:HasModifier("modifier_item_sa_bloodblade") then
		local ability = caster:FindModifierByName("modifier_item_sa_bloodblade"):GetAbility()
		local vamp_prt = ability:GetSpecialValueFor("vamp_prt")
		vamp_mod.vamp_prt = vamp_prt
	else
		caster:FindModifierByName("modifier_item_vamp").vamp_prt = 0
		caster:RemoveModifierByName("modifier_item_vamp")
	end
end
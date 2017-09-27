function OnEquipGiantAxe(event)
	Timers:CreateTimer(0.01,function()
		if event.caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			if not event.caster:HasModifier("modifier_sa_lightning_axe_cleave") then
				local item = GetItemInInventory(event.caster,"item_sa_giant_axe")
				item:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_sa_giant_axe_cleave", nil)
			end
		end
	end)
end

function OnEquipLightningAxe(event)
	Timers:CreateTimer(0.01,function()
		if event.caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			event.caster:RemoveModifierByName("modifier_sa_giant_axe_cleave")
			local item = GetItemInInventory(event.caster,"item_sa_lightning_axe")
			item:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_sa_lightning_axe_cleave", nil) 
		end
	end)
end

function OnUnequip(event)
	if not event.caster:HasModifier("modifier_sa_giant_axe") then
		event.caster:RemoveModifierByName("modifier_sa_giant_axe_cleave")
	end
	if not event.caster:HasModifier("modifier_sa_lightning_axe") then
		event.caster:RemoveModifierByName("modifier_sa_lightning_axe_cleave")
		if event.caster:HasModifier("modifier_sa_giant_axe") then
			local item = GetItemInInventory(event.caster,"item_sa_giant_axe")
			item:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_sa_giant_axe_cleave", nil) 	
		end
	end
end
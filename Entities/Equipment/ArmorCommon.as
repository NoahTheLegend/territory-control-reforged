void SetArmorHealth(CBlob@ this, string propname, f32 &out armorMaxHealth, f32 &out min_armor_health)
{
	if (propname == "militaryhelmet" || propname == "nvd")
	{
		armorMaxHealth = 85.0f;
		min_armor_health = 15.0f;
	}
	else if (propname == "carbonhelmet")
	{
		armorMaxHealth = 190.0f;
		min_armor_health = 40.0f;
	}
	else if (propname == "scubagear")
	{
		armorMaxHealth = 10.0f;
		min_armor_health = 1.0f;
	}
	else if (propname == "bucket")   
	{
		armorMaxHealth = 10.0f;
		min_armor_health = 1.0f;
	}
	else if (propname == "pumpkin")  
	{
		armorMaxHealth = 5.0f;
		min_armor_health = 0.5f;
	}
	else if (propname == "minershelmet")
	{
		armorMaxHealth = 10.0f;
		min_armor_health = 1.0f;
	}
	else if (propname == "bulletproofvest") 
	{
		armorMaxHealth = 100.0f;
		min_armor_health = 25.0f;
	}
	else if (propname == "carbonvest") 
	{
		armorMaxHealth = 200.0f;
		min_armor_health = 40.0f;
	}
	else if (propname == "keg") 		
	{
		armorMaxHealth = 10.0f;
		min_armor_health = 1.0f;
	}
	else if (propname == "combatboots")
	{
		armorMaxHealth = 48.0f;
		min_armor_health = 16.0f;
	}
	else if (propname == "carbonboots")
	{
		armorMaxHealth = 98.0f;
		min_armor_health = 28.0f;
	}
	
    if (armorMaxHealth <= 0) armorMaxHealth = 10.0f;
    if (min_armor_health < 0) min_armor_health = 1.0f;
    
	this.set_f32(propname+"_maxhealth", armorMaxHealth);
	this.set_f32(propname+"_minhealth", min_armor_health);
}
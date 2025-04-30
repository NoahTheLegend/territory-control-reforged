void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "bulletproofvest")
		this.set_string("reload_script", "");
	
	f32 hp = this.get_f32("bulletproofvest_health");
    f32 max_health = this.get_f32("bulletproofvest_maxhealth");
    f32 min_health = this.get_f32("bulletproofvest_minhealth");
	
	if (hp > max_health)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_torso", "");
        this.set_f32("bulletproofvest_health", max_health);
		this.RemoveScript("bulletproofvest_effect.as");
    }
}
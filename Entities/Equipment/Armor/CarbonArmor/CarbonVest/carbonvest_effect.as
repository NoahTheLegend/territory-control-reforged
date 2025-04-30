#include "RunnerCommon.as"

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "carbonvest")
		this.set_string("reload_script", "");
	
	RunnerMoveVars@ moveVars;
    if (this.get("moveVars", @moveVars))
    {
        moveVars.walkFactor *= 0.95f;
    }
	
	f32 hp = this.get_f32("carbonvest_health");
    f32 max_health = this.get_f32("carbonvest_maxhealth");
    f32 min_health = this.get_f32("carbonvest_minhealth");
	
	if (hp > max_health)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_torso", "");
        this.set_f32("carbonvest_health", max_health);
		this.RemoveScript("carbonvest_effect.as");
    }
}
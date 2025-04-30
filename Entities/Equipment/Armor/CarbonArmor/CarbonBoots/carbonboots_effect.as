#include "RunnerCommon.as"

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "carbonboots")
        this.set_string("reload_script", "");
    
    RunnerMoveVars@ moveVars;
    if (this.get("moveVars", @moveVars))
    {
        moveVars.walkFactor *= 1.05f;
    }
    
    f32 hp = this.get_f32("carbonboots_health");
    f32 max_health = this.get_f32("carbonboots_maxhealth");
    f32 min_health = this.get_f32("carbonboots_minhealth");
	
	if (hp > max_health)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_boots", "");
        this.set_f32("carbonboots_health", max_health);
		this.RemoveScript("carbonboots_effect.as");
    }
}
#include "RunnerCommon.as"

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "combatboots")
        this.set_string("reload_script", "");
    
    RunnerMoveVars@ moveVars;
    if (this.get("moveVars", @moveVars))
    {
        moveVars.walkFactor *= 1.15f;
    }
    
    f32 hp = this.get_f32("combatboots_health");
    f32 max_health = this.get_f32("combatboots_maxhealth");
    f32 min_health = this.get_f32("combatboots_minhealth");
	
	if (hp > max_health)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_boots", "");
        this.set_f32("combatboots_health", max_health);
		this.RemoveScript("combatboots_effect.as");
    }
}
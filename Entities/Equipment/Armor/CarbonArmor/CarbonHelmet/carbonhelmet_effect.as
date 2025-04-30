#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if (this.get_string("reload_script") != "carbonhelmet")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
    CSpriteLayer@ milhelmet = this.getSprite().addSpriteLayer("carbonhelmet", "CarbonHelmet.png", 16, 16);
   
    if (milhelmet !is null)
    {
        milhelmet.addAnimation("default", 0, true);
		int[] frames = {0, 1, 2, 3};
		milhelmet.animation.AddFrames(frames);
		//milhelmet.SetAnimation(anim);
		
		milhelmet.SetVisible(true);
        milhelmet.SetRelativeZ(200);
        if (this.getSprite().isFacingLeft())
            milhelmet.SetFacingLeft(true);
    }
}
 
void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "carbonhelmet")
    {
        UpdateScript(this);
        this.set_string("reload_script", "");
    }

    f32 hp = this.get_f32("carbonhelmet_health");
    f32 max_health = this.get_f32("carbonhelmet_maxhealth");
    f32 min_health = this.get_f32("carbonhelmet_minhealth");
 
    CSpriteLayer@ milhelmet = this.getSprite().getSpriteLayer("carbonhelmet");
    if (milhelmet !is null)
    {
        Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
        Vec2f head_offset = getHeadOffset(this, -1, 0);
        
        headoffset += this.getSprite().getOffset();
        headoffset += Vec2f(-head_offset.x, head_offset.y);
        headoffset += Vec2f(0, -1);
        milhelmet.SetOffset(headoffset);
        milhelmet.animation.frame = Maths::Floor((hp * 3.0f) / max_health) / 3.0f;
    }

    if (hp > max_health)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_head", "");
        this.set_f32("carbonhelmet_health", max_health);

		if (milhelmet !is null) this.getSprite().RemoveSpriteLayer("carbonhelmet");
        this.RemoveScript("carbonhelmet_effect.as");
    }
}
 
void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ item = server_CreateBlob("carbonhelmet", this.getTeamNum(), this.getPosition());
		if (item !is null)
		{
            f32 hp = this.get_f32("carbonhelmet_health");
			item.set_f32("health", hp);
		}
	}
	
	if (this.getSprite().getSpriteLayer("carbonhelmet") !is null) this.getSprite().RemoveSpriteLayer("carbonhelmet");
    this.RemoveScript("carbonhelmet_effect.as");
}
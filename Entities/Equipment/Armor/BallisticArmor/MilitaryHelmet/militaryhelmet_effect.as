#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if (this.hasTag("bushy")) this.Tag("disguised");
	if (this.get_string("reload_script") != "militaryhelmet")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
    CSpriteLayer@ milhelmet = this.getSprite().addSpriteLayer("militaryhelmet", "MilitaryHelmet.png", 16, 16);
   
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

    if (this.hasTag("bushy"))
    {
	    CSpriteLayer@ bushy = this.getSprite().addSpriteLayer("bushy", "Bushes.png", 24, 24);

		if (bushy !is null)
		{
			milhelmet.SetVisible(false);
			bushy.SetVisible(true);
			bushy.SetRelativeZ(200);
			if (this.getSprite().isFacingLeft())
				bushy.SetFacingLeft(true);
		}
	}
}
 
void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "militaryhelmet")
    {
        UpdateScript(this);
        this.set_string("reload_script", "");
    }

    f32 hp = this.get_f32("militaryhelmet_health");
    f32 max_health = this.get_f32("militaryhelmet_maxhealth");
    f32 min_health = this.get_f32("militaryhelmet_minhealth");
 
    CSpriteLayer@ milhelmet = this.getSprite().getSpriteLayer("militaryhelmet");
    if (milhelmet !is null)
    {
        Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
        Vec2f head_offset = getHeadOffset(this, -1, 0);
        
        headoffset += this.getSprite().getOffset();
        headoffset += Vec2f(-head_offset.x, head_offset.y);
        headoffset += Vec2f(0, -1);
        milhelmet.SetOffset(headoffset);
        milhelmet.animation.frame = 3 - (Maths::Round(hp * 4.0f) / max_health - 1);
		
        CSpriteLayer@ bushy = this.getSprite().getSpriteLayer("bushy");
        if (this.hasTag("bushy") && bushy !is null)
        {
        	bushy.SetOffset(headoffset + Vec2f(1, 1));
        }
    }

    if (hp > max_health)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_head", "");
        this.set_f32("militaryhelmet_health", max_health);

		if (milhelmet !is null) this.getSprite().RemoveSpriteLayer("militaryhelmet");
        this.RemoveScript("militaryhelmet_effect.as");
    }
}
 
void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ item = server_CreateBlob("militaryhelmet", this.getTeamNum(), this.getPosition());
		if (item !is null)
		{
			if (this.hasTag("bushy")) item.Tag("bushy");

            f32 hp = this.get_f32("militaryhelmet_health");
			item.set_f32("health", hp);
		}
	}
	
	if (this.getSprite().getSpriteLayer("bushy") !is null) this.getSprite().RemoveSpriteLayer("bushy");
	if (this.getSprite().getSpriteLayer("militaryhelmet") !is null) this.getSprite().RemoveSpriteLayer("militaryhelmet");
    this.RemoveScript("militaryhelmet_effect.as");
}
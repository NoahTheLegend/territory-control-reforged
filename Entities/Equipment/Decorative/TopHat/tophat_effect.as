#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if (this.get_string("reload_script") != "tophat")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
	//this.SetLight(true);
	//this.SetLightRadius(80.0f);
	//this.SetLightColor(SColor(255, 255, 240, 171));
	
	CSpriteLayer@ tophat = this.getSprite().addSpriteLayer("tophat", "TopHat.png", 16, 16);
	

	if (tophat !is null)
	{
		tophat.SetVisible(true);
		tophat.SetRelativeZ(200);
		if (this.getSprite().isFacingLeft())
			tophat.SetFacingLeft(true);
	}
}

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "tophat")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}

	CSpriteLayer@ tophat = this.getSprite().getSpriteLayer("tophat");
	if (tophat !is null)
	{
		Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(this, -1, 0);
		
		headoffset += this.getSprite().getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(0, -3);
		tophat.SetOffset(headoffset);
	}
}
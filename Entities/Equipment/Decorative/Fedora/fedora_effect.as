#include "PixelOffsets.as";
#include "RunnerTextures.as";

void onInit(CBlob@ this)
{
	if (this.get_string("reload_script") != "fedora")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
	//this.SetLight(true);
	//this.SetLightRadius(80.0f);
	//this.SetLightColor(SColor(255, 255, 240, 171));
	
	CSpriteLayer@ fedora = this.getSprite().addSpriteLayer("fedora", "Fedora.png", 16, 16);
	

	if (fedora !is null)
	{
		fedora.SetVisible(true);
		fedora.SetRelativeZ(200);
		if (this.getSprite().isFacingLeft()) fedora.SetFacingLeft(true);
	}
}

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "fedora")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
	
	CSpriteLayer@ fedora = this.getSprite().getSpriteLayer("fedora");
	
	if (fedora !is null)
	{
		Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(this, -1, 0);
		
		headoffset += this.getSprite().getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(0, -3);
		fedora.SetOffset(headoffset);
	} 
}
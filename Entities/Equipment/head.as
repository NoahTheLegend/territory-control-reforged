void onInit(CBlob@ this)
{
	this.Tag("head");

	if (this.getName() == "militaryhelmet" || this.getName() == "carbonhelmet" || this.getName() == "nvd")
		this.Tag("armor");

	this.getCurrentScript().tickFrequency = 300;
}

void onTick(CBlob@ this)
{
	if (!isClient()) return;

	f32 hp = this.get_f32("health");
	f32 max_health = this.get_f32("max_health");

	if (hp != 0 && max_health != 0)
	{
		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;

		f32 frame = 3 - (Maths::Round(hp * 4.0f) / max_health - 1);
		if (sprite.animation !is null) sprite.animation.frame = frame;
		this.inventoryIconFrame = frame;
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ blob)
{
	onTick(this);
}
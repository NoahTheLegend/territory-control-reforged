// TrapBlock.as

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(10);
	this.getShape().SetRotationsAllowed(false);

	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (blob.hasTag("player")) return;
	
	if (this.hasBlob(blob.getConfig(), 0) || this.hasBlob(blob.getConfig(), 1))
	{
		blob.setVelocity(Vec2f(this.isFacingLeft() ? -1 : 1, -6));
		this.getSprite().PlaySound("/launcher_boing" + XORRandom(2) + ".ogg", 0.5f, 0.9f);
	}
	else if (Maths::Abs(blob.getVelocity().y) < 2.0f) blob.setVelocity(Vec2f(this.isFacingLeft() ? -1 : 1, -1.0f));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
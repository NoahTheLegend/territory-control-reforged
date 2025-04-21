// TrapBlock.as

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(10);

	this.getShape().SetRotationsAllowed(false);

	this.set_bool("open", false);
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
	if (!blob.hasTag("player") && blob.getVelocity().y < 0.0f && blob.getPosition().y > this.getPosition().y)
	{
		return false;
	}
	else if ((blob.isKeyPressed(key_down) && blob.getVelocity().y > 0) || (blob.isKeyPressed(key_up) && blob.getVelocity().y < 0))
	{
		return false;
	}

	return !(this.hasBlob(blob.getConfig(), 0) || this.hasBlob(blob.getConfig(), 1));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	if (blob.hasTag("player"))return;
	
	if (Maths::Abs(blob.getVelocity().y) < 2.0f) blob.setVelocity(Vec2f(this.isFacingLeft() ? -1 : 1, -1.0f));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
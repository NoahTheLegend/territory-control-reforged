// TrapBlock.as

#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	// this.set_TileType("background tile", CMap::tile_castle_back);

	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("forward");
	
	this.addCommandID("server use");
	this.addCommandID("client use");
	
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

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	MakeDamageFrame(this);
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ((hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	if (blob.hasTag("player")) return;
	
	blob.setVelocity(Vec2f(this.isFacingLeft() ? -1 : 1, -6));
	
	this.getSprite().PlaySound("/launcher_boing" + XORRandom(2) + ".ogg", 0.5f, 0.9f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getCarriedBlob() !is this)
	{
		const int icon = this.isFacingLeft() ? 17 : 18;
		caller.CreateGenericButton(icon, Vec2f(0, 0), this, this.getCommandID("server use"), "flip");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server use") && isServer())
	{
		const bool left = this.isFacingLeft();
		this.SetFacingLeft(!left);
		
		CBitStream stream;
		stream.write_bool(!left);
		this.SendCommand(this.getCommandID("client use"), stream);
	}
	else if (cmd == this.getCommandID("client use") && isClient())
	{
		this.SetFacingLeft(params.read_bool());
	}
}

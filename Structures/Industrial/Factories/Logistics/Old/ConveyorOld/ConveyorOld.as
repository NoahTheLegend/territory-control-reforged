// TrapBlock.as

#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(10);
	this.getShape().SetRotationsAllowed(false);

	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	// this.set_TileType("background tile", CMap::tile_castle_back);

	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	// CSprite@ sprite = this.getSprite();
	// sprite.SetAnimation("forward");
	
	// this.addCommandID("use");
	
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
	if (!isOpen(this))
	{
		MakeDamageFrame(this);
	}
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ((hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	// if (blob.hasTag("player") && blob.getTeamNum() == this.getTeamNum()) return;
	if (blob.hasTag("player")) return;
	
	if (Maths::Abs(blob.getVelocity().y) < 2.0f) blob.setVelocity(Vec2f(this.isFacingLeft() ? -1 : 1, -1.0f));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder) damage *= 4.0f;

	return damage;
}


// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// if (caller.getCarriedBlob() !is this){
		// CBitStream params;
		// params.write_u16(caller.getNetworkID());
		
		// int icon = 17;
		// if (this.isFacingLeft())icon = 18;
		
		// CButton@ button = caller.CreateGenericButton(icon, Vec2f(0,0), this, this.getCommandID("use"), "Reverse Direction", params);
	// }
// }


// void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
// {
	// CBlob@ caller = getBlobByNetworkID(params.read_u16());
	// if    (caller !is null)
	// {
		// if (cmd == this.getCommandID("use"))
		// {
			// this.SetFacingLeft(!this.isFacingLeft());
		// }
	// }
// }
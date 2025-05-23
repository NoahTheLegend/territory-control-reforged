#include "Hitters.as";
#include "Explosion.as";

const u32 fuel_timer_max = 20;

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.1f);
	this.set_f32("map_damage_radius", 16.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");

	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 10.0f);

	this.Tag("aerial");
	this.Tag("projectile");
	this.Tag("bullet_collision");

	this.getShape().SetRotationsAllowed(true);

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	this.set_u32("fuel_timer", getGameTime() + fuel_timer_max + XORRandom(15));

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Rocket_Idle.ogg");
	sprite.SetEmitSoundSpeed(2.0f);
	sprite.SetEmitSoundPaused(false);

	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 100, 0));
}

void onTick(CBlob@ this)
{
	if (this.get_u32("fuel_timer") > getGameTime())
	{
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.15f, 15.0f));

		Vec2f dir = Vec2f(0, 1);
		dir.RotateBy(this.getAngleDegrees());

		this.setVelocity(dir * -this.get_f32("velocity") + Vec2f(0, this.getTickSinceCreated() > 5 ? XORRandom(50) / 100.0f : 0));

		if(isClient())
		{
			MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}

		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
	}
	else
	{
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
		this.getSprite().SetEmitSoundPaused(true);
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	Vec2f offset = Vec2f(XORRandom(16)-8, XORRandom(8)-4).RotateBy(this.getAngleDegrees());
	CMap@ map = getMap(); // fire things up if standing under
	if (isServer() && map !is null)
	{
		for (u8 i = 0; i < 10; i++)
		{
			map.server_setFireWorldspace(this.getPosition()+offset+Vec2f(XORRandom(24)-12, XORRandom(32)-16), true);
		}
	}
	if (!isClient()) return;
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, velocity, DoExplosion);
		return;
	}

	if (this.hasTag("dead")) return;
	this.Tag("dead");

	this.set_Vec2f("explosion_offset", Vec2f(0, -16).RotateBy(this.getAngleDegrees()));

	Explode(this, 8.0f, 3.0f);
	for (int i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);

		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 16.0f + XORRandom(16), 10.0f, 4, 5.0f, Hitters::explosion);
	}

	this.server_Die();
	this.getSprite().Gib();
}

void onDie(CBlob@ this)
{
	DoExplosion(this, Vec2f(0, 0));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTickSinceCreated() > 5 && this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!isServer()) return;

	if (this.hasTag("collided")) return;
	
	bool blob_exists = blob !is null;


	if (blob_exists && blob.getShape().isStatic() && blob.getShape().getConsts().collidable)
	{
		this.server_Die();
		return;
	}


	if (this.getTickSinceCreated()<=3) return;


	if (blob_exists && blob.hasTag("vehicle"))
	{
		this.server_Hit(blob, this.getPosition(), this.getVelocity(), 3, Hitters::explosion, false);
		this.Tag("collided");
		this.server_Die();
		return;
	}


	if ((solid ? true : (blob !is null && blob.isCollidable() && this.getTeamNum() != blob.getTeamNum())))
	{
		this.server_Die();
	}
}

// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	// if (point is null) return;

	// if (point.getOccupied() is null)
	// {
		// CBitStream params;
		// caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	// }
// }

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	// if (point is null) return true;

	// CBlob@ holder = point.getOccupied();
	// if (holder is null) return true;
	// else return false;
}

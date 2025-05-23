#include "VehicleCommon.as"
#include "Hitters.as";

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              0, // move speed
	              0.0f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	
	//this.getShape().SetOffset(Vec2f(0, 8));
	
	this.Tag("ignore fall");
	this.Tag("heat signature");

	CShape@ shape = this.getShape();
	shape.SetGravityScale(1.0f);
	
	AttachmentPoint@ driverpoint = this.getAttachments().getAttachmentPointByName("PASSENGER");
	if (driverpoint !is null)
	{
		driverpoint.SetKeysToTake(key_action2);
		driverpoint.SetKeysToTake(key_left);
		driverpoint.SetKeysToTake(key_right);
	}
	
	this.getShape().SetRotationsAllowed(true);

	this.set_string("last_driver_username", "");
	this.set_u16("last_driver_blobid", 0);
	this.set_u16("last_attacker_blobid", 0);
	this.set_s32("cancel_go_back", 0);
	this.set_u8("next_attack", 30);

	this.Tag("allow guns");
}

void onTick(CBlob@ this)
{

	s32 gametime = getGameTime();
	if (this.hasTag("mad"))
	{
		this.set_u8("mad_timer_seconds", XORRandom(5)+5);
		//additional code goes here

		this.Untag("mad");
	}
	if (!this.isOnGround()) this.AddForce(Vec2f(0, 75.0f));
	CBlob@ target = getBlobByNetworkID(this.get_u16("last_attacker_blobid"));
	Vec2f vel = this.getVelocity();
	Vec2f tpos;
	Vec2f pos = this.getPosition();
	if (target !is null)
	{
		tpos = target.getPosition();
		if (this.isOverlapping(target) && this.get_u8("next_attack") == 0)
		{
			if (isClient())
			{
				this.getSprite().PlaySound("ZombieBite.ogg", 1.0f, 1.2f);
				this.getSprite().PlaySound("badger_pissed.ogg", 1, 0.8+XORRandom(8)*0.1f);
			}
			if (isServer()) this.server_Hit(target, tpos, vel, 0.5f+XORRandom(2), Hitters::bite, false);
			
			this.set_u8("next_attack", XORRandom(30)+30);
		}
	}

	if (this.get_u8("next_attack") > 0) this.add_u8("next_attack", -1);
	Vec2f dir = tpos - pos;
	dir.Normalize();
	if (vel.x > 1.0f) this.SetFacingLeft(false);
	else if (vel.x < -1.0f) this.SetFacingLeft(true);
	if (this.get_u8("mad_timer_seconds") > 0)
	{
		if (this.get_u16("last_attacker_blobid") == 0)
		{
			if (this.hasTag("mad_at_left"))
			{
				if(gametime%2==0) this.AddForce(Vec2f(-250.0f,-1.0f));
			}
			else if (this.hasTag("mad_at_right"))
			{
				if(gametime%2==0) this.AddForce(Vec2f(250.0f,-1.0f));
			}
		}
		else
		{
			if (gametime%2==0 && target !is null)
			{
				if (this.getDistanceTo(target) > 1080.0f) return;
				if (gametime % 30 == 0 && XORRandom(4) == 0) this.add_u8("mad_timer_seconds", 1);
				
				if (dir.x < 0)
				{
					f32 rev = 1.0f;
					if (this.hasTag("go_back")) rev = -1.0f;

					this.AddForce(Vec2f(-250.0f*rev,-1.0f));
					f32 angle = this.getAngleDegrees();
					bool faceleft = this.isFacingLeft();
					if (rev == -1.0f) faceleft = !faceleft;
					if (angle > 330 || angle < 30)
					{
						f32 wallMultiplier = (this.isOnWall() && (angle > 260 || angle < 100)) ? 1.5f : 1.0f;
						f32 torque = 150.0f * wallMultiplier;
						if (dir.y > 0)
							this.AddTorque(faceleft ? torque : -torque);
						else
							this.AddTorque(((faceleft && dir.x < 0) || (!faceleft && dir.x > 0)) ? torque : -torque);
						this.AddForce(Vec2f(0.0f, -200.0f * wallMultiplier));
					}
				}
				else if (dir.x > 0)
				{
					f32 rev = 1.0f;
					if (this.hasTag("go_back")) rev = -1.0f;

					this.AddForce(Vec2f(250.0f*rev,-1.0f));
					f32 angle = this.getAngleDegrees();
					bool faceleft = this.isFacingLeft();
					if (rev == -1.0f) faceleft = !faceleft;
					if (angle > 330 || angle < 30)
					{
						f32 wallMultiplier = (this.isOnWall() && (angle > 260 || angle < 100)) ? 1.5f : 1.0f;
						f32 torque = 150.0f * wallMultiplier;
						if (dir.y > 0)
							this.AddTorque(faceleft ? torque : -torque);
						else
							this.AddTorque(((faceleft && dir.x < 0) || (!faceleft && dir.x > 0)) ? torque : -torque);
						this.AddForce(Vec2f(0.0f, -200.0f * wallMultiplier));
					}
				}
			}
		}
		//jump if stuck
		CMap@ map = getMap();
		if (map is null) return;
		if (!this.hasTag("go_back") && vel.x < 0.75f && vel.y > -0.75f && map.rayCastSolid(pos, tpos))
		{
			this.AddForce(Vec2f(0,-185.0f));
			if (XORRandom(250) == 0)
			{
				this.Tag("go_back");
			}
		}
		else if (this.hasTag("go_back"))
		{
			if (!this.hasTag("set_time"))
			{
				this.Tag("set_time");
				this.set_s32("cancel_go_back", gametime+XORRandom(30)+30);
			}
			else if (this.get_s32("cancel_go_back") <= gametime)
			{
				this.Untag("go_back");
				this.Untag("go_left");
				this.Untag("go_right");
				this.Untag("set_time");
			}
		}

		//if (this.isOnWall()) this.AddForce(Vec2f(0,-185.0f));
		if (gametime % 30 == 0) this.set_u8("mad_timer_seconds", this.get_u8("mad_timer_seconds") - 1);
	}
	CShape@ shape = this.getShape();
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PASSENGER");
		CBlob@ driver = point.getOccupied();
		
		if (driver !is null)
		{
			ResetMadness(this);
			CPlayer@ driverp = driver.getPlayer();
			if (driverp !is null) this.set_string("last_driver_username", driverp.getUsername());
			this.set_u16("last_driver_blobid", driver.getNetworkID());

			if (point.isKeyPressed(key_action2) && this.isOnGround())
			{
				this.AddForce(Vec2f(0.0f, -1000.0f));
			}
			if (point.isKeyPressed(key_left))
			{
				this.setVelocity(Vec2f(-5.0f, this.getVelocity().y));
			}
			if (point.isKeyPressed(key_right))
			{
				this.setVelocity(Vec2f(5.0f, this.getVelocity().y));
			}
		}
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}

		Vehicle_StandardControls(this, v);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead")) 
	{
		this.getCurrentScript().removeIfTag = "dead";
		return;
	}
	else
	{
		f32 x = Maths::Abs(blob.getVelocity().x);

		if (Maths::Abs(x) > 1.5f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
}

void ResetMadness(CBlob@ this)
{
	this.Untag("mad_at_left");
	this.Untag("mad_at_right");
	this.set_u16("last_attacker_blobid", 0);
}

/*f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is null) return damage;

	ResetMadness(this); // cancel previous madness

	if (hitterBlob !is null)
		this.set_u16("last_attacker_blobid", hitterBlob.getNetworkID()); // remember the blobid of attacker

	if (velocity.x > 0.25f) this.Tag("mad_at_left");
	else if (velocity.x < -0.25f) this.Tag("mad_at_right");

	this.Tag("mad");

	return damage; //no block, damage goes through
}*/

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}
void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused) {}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.hasTag("vehicle") && this.getTeamNum() == byBlob.getTeamNum();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() ? blob.isCollidable() : false;
}

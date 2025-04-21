#include "Hitters.as";

const u32 fuel_timer_max = 30 * 5;

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("aerial");
	
	this.Tag("explosive");
	this.Tag("heavy weight");

	this.addCommandID("offblast");
	this.addCommandID("attachBomb");
	this.addCommandID("detachBomb");
	
	this.set_u32("no_explosion_timer", 0);
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 5.0f);
	this.set_f32("max_velocity", 15.0f);
	
	this.set_u16("controller_blob_netid", 0);
	this.set_u16("controller_player_netid", 0);

	this.set_u16("inv_count", 0);
	this.set_string("inv_name", "");
	this.set_f32("factor", 1.0f);

	this.getShape().SetRotationsAllowed(true);
}

void onDie(CBlob@ this)
{	
	ResetPlayer(this);

	CInventory@ inv = this.getInventory();
	if (inv is null) return;

	if (isServer() && this.get_u16("inv_count") >= 75 && this.get_string("inv_name") == "mat_fuel")
	{
		CBlob@ thermobaric = server_CreateBlob("thermobaricexplosion", this.getTeamNum(), this.getPosition());
		if (thermobaric !is null)
		{
			thermobaric.set_f32("boom_end", 240);
		 	thermobaric.set_u32("boom_delay", 15);
		}
	}
	
	AttachmentPoint@ bomb_point = this.getAttachments().getAttachmentPointByName("BOMB");
	if (bomb_point is null) return;

	CBlob@ bomb = bomb_point.getOccupied();
	if (bomb is null) return;

	string bomb_name = bomb.getName();
	
	if (bomb.hasTag("dangerous")) {
		if (bomb_name != "bombita")
			bomb.server_Die();
		if (bomb.hasTag("explosive"))
			bomb.Tag("DoExplode");
	}
	
	if (bomb_name == "bombita") {
		bomb.set_bool("exploding", true);
	} else if (bomb_name == "mat_acid") {
		if (!isServer()) return;
		Vec2f velocity = this.getVelocity();
		f32 angle = velocity.getAngleDegrees();
		
		f32 quantity = bomb.getQuantity() / 4;
		for (int i = 0; i < (quantity) ; i++)
		{
			CBlob@ blob = server_CreateBlob("acidgas", -1, this.getPosition());
			blob.setVelocity(velocity + Vec2f(20 - XORRandom(40), 5 - XORRandom(10)).RotateByDegrees(angle));
		}
	} else if (bomb_name == "mat_mustard") {
		if (!isServer()) return;
		Vec2f velocity = this.getVelocity();
		f32 angle = -velocity.getAngleDegrees() + 180.00f;
		
		f32 quantity = bomb.getQuantity() / 8;
		for (int i = 0; i < (quantity) ; i++)
		{
			CBlob@ blob = server_CreateBlob("mustard", -1, this.getPosition());
			blob.setVelocity(velocity + Vec2f(20 - XORRandom(40), 5 - XORRandom(10)).RotateByDegrees(angle));
		}
	} else if (bomb_name == "crate" || bomb.hasTag("player")) {
		bomb.Tag("parachute");
		bomb.setAngleDegrees(0);
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ bomb_point = this.getAttachments().getAttachmentPointByName("BOMB");
	if (this.hasTag("offblast"))
	{
		Vec2f dir;
	
		if (this.get_u32("fuel_timer") > getGameTime())
		{
			CPlayer@ controller = this.getPlayer();
			this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.3f, this.get_f32("max_velocity")));
			
			CBlob@ blob = getBlobByNetworkID(this.get_u16("controller_blob_netid"));
			bool isControlled = blob !is null && !blob.hasTag("dead");
			
			if (!isControlled || controller is null || this.get_f32("velocity") < this.get_f32("max_velocity") * 0.75f)
			{
				dir = Vec2f(0, 1);
				dir.RotateBy(this.getAngleDegrees());
			}
			else
			{
				dir = (this.getPosition() - this.getAimPos());
				dir.Normalize();
			}
						
			// print(this.getAimPos().x + " " + this.getAimPos().y);
						
			const f32 ratio = 0.20f;
			
			Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
			nDir.Normalize();
			
			this.SetFacingLeft(false);
			
			this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.75f, 20.0f));
			this.set_Vec2f("direction", nDir);
			
			this.setAngleDegrees(-nDir.getAngleDegrees() + 90 + 180);
			this.setVelocity(-nDir * this.get_f32("velocity"));
			
			MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}
		else
		{
			this.setAngleDegrees(-this.getVelocity().Angle() + 90);
			this.getSprite().SetEmitSoundPaused(true);
		}
		
		if (this.get_u32("no_explosion_timer") < getGameTime())
		{
			if (isServer())
			{
				if (this.isKeyJustPressed(key_action1)) {
					ResetPlayer(this);
					UpdateInventory(this);
					this.server_Die();
					return;
				}
				else if (this.isKeyJustPressed(key_action2)) {
					if (bomb_point !is null) {
						CBlob@ bomb = bomb_point.getOccupied();
						if (bomb !is null) {
							if (!(bomb.hasTag("dangerous")||bomb.hasTag("explosive"))) {
								bomb.server_DetachFrom(this);
								bomb.setPosition(this.getPosition() + Vec2f(0, 8).RotateByDegrees(this.getAngleDegrees()));
								bomb.setAngleDegrees(0);
								ResetPlayer(this);
							}
						}
					}
				}
			}
		}
	}
	
	if (bomb_point !is null) {
		CBlob@ bomb = bomb_point.getOccupied();
		if (bomb !is null) {
			//print ("hey!");
			bomb.setAngleDegrees(this.getAngleDegrees()+(bomb.hasTag("explosive")?180:0));
			if (bomb.hasTag("explosive"))
				bomb.set_f32("bomb angle", -this.getVelocity().Angle()); //for bunker busters and other bombs that care about bomb angle
				//doesn't seem working tho....
			bomb.SetFacingLeft(!this.isFacingLeft());
			bomb_point.offsetZ = this.getSprite().getRelativeZ()+2;
		}
	}
}

void UpdateInventory(CBlob@ this)
{
	if (!isServer()) return;

	CInventory@ inv = this.getInventory();
	if (inv is null) return;

	this.set_u16("inv_count", 0);
	this.set_string("inv_name", "");

	bool explode_inv = true;
	CBlob@ item = inv.getItem(0);
	if (item !is null)
	{
		this.set_u16("inv_count", inv.getCount(item.getName()));
		this.set_string("inv_name", item.getName());

		if (item.getName() == "mat_fuel")
		{
			explode_inv = false;
		}
	}

	if (explode_inv)
	{
		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			if (item !is null)
			{
				item.Tag("DoExplode");
				item.server_Die();
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if ((blob !is null ? !blob.isCollidable() : !solid)) return;
		if (this.hasTag("offblast"))
		{
			ResetPlayer(this);
			UpdateInventory(this);
			this.server_Die();
		}
	}
}

void ResetPlayer(CBlob@ this)
{
	if (isServer())
	{
		CPlayer@ ply = getPlayerByNetworkId(this.get_u16("controller_player_netid"));
		CBlob@ blob = getBlobByNetworkID(this.get_u16("controller_blob_netid"));
		if (blob !is null && ply !is null && !blob.hasTag("dead"))
		{
			blob.server_SetPlayer(ply);
			//getCamera().setTarget(blob);
		}
	}
}

shared const bool isTargetVisible(CBlob@ this, CBlob@ target)
{
	Vec2f col;
	
	if (getMap().rayCastSolid(this.getPosition(), target.getPosition(), col))
	{
		// fix for doors not being considered visible
		CBlob@ obstruction = getMap().getBlobAtPosition(col);
		if (obstruction is null || obstruction !is target)
			return false;
	}
	return true;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isAttached()) return;

	if (isTargetVisible(caller, this))
	{
		CPlayer@ ply = caller.getPlayer();
		if (ply !is null)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u16(ply.getNetworkID());
			
			CBlob@ carried = caller.getCarriedBlob();
			if (carried is null)
				caller.CreateGenericButton(11, Vec2f(0.0f, -8.0f), this, this.getCommandID("offblast"), "Off blast!", params);
			if (caller is null) return;
			
			AttachmentPoint@ bomb_point = this.getAttachments().getAttachmentPointByName("BOMB");
			if (bomb_point is null) return;

			CInventory@ inv = this.getInventory();
			if (inv is null) return;

			CBlob@ item = inv.getItem(0);
			if (item !is null) return;

			CBlob@ bomb = bomb_point.getOccupied();
			if (bomb is null) {
				if (carried is null || carried is this || carried.getName()==this.getName() || carried.hasTag("gun") || (carried.hasTag("material") && !carried.hasTag("explosive")&&!carried.hasTag("dangerous"))) return;
				CBitStream params_2;
				params_2.write_u16(carried.getNetworkID());
				caller.CreateGenericButton("$"+carried.getName()+"$", Vec2f(0.0f, -8.0f), this, this.getCommandID("attachBomb"), "Attach "+carried.getInventoryName()+" to the missile", params_2);
			} else if (carried !is null) {
				caller.CreateGenericButton("$"+bomb.getName()+"$", Vec2f(0.0f, -8.0f), this, this.getCommandID("detachBomb"), "Detach "+bomb.getInventoryName()+" from the missile");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("attachBomb"))
	{
		if (this.hasTag("offblast")) return;
		u16 bomb_netid;

		CInventory@ inv = this.getInventory();
		if (inv is null) return;

		CBlob@ item = inv.getItem(0);
		if (item !is null) return;

		if (!params.saferead_u16(bomb_netid)) return;
		if (bomb_netid == 0) return;

		CBlob@ bomb = getBlobByNetworkID(bomb_netid);
		if (bomb is null) return;
		if (bomb.getName() == "wrench") return;

		bomb.server_DetachFromAll();
		bomb.setPosition(this.getPosition() + Vec2f(0, 8).RotateByDegrees(this.getAngleDegrees()));

		this.server_AttachTo(bomb, "BOMB");
	}
	if (cmd == this.getCommandID("detachBomb"))
	{
		AttachmentPoint@ bomb_point = this.getAttachments().getAttachmentPointByName("BOMB");
		if (bomb_point is null) return;
		CBlob@ bomb = bomb_point.getOccupied();
		if (bomb is null) return;
		bomb.server_DetachFrom(this);
		bomb.setPosition(this.getPosition() + Vec2f(0, 8).RotateByDegrees(this.getAngleDegrees()));
		bomb.setAngleDegrees(0);
	}
	if (cmd == this.getCommandID("offblast"))
	{
		const u16 caller_netid = params.read_u16();
		const u16 player_netid = params.read_u16();
		
		if (player_netid == 0) return;
		CPlayer@ ply = getPlayerByNetworkId(player_netid);
	
		if (this.hasTag("offblast")) return;
		
		this.Tag("projectile");
		this.Tag("offblast");
		
		this.server_DetachFromAll();
		
		f32 factor = 1.0f;
		AttachmentPoint@ bomb_point = this.getAttachments().getAttachmentPointByName("BOMB");
		if (bomb_point !is null) {
			CBlob@ bomb = bomb_point.getOccupied();
			if (bomb !is null)
			{
				if (bomb.hasTag("medium weight")) factor = 2.0f;
				else if (bomb.hasTag("heavy weight")) factor = 3.0f;
			}
		}

		this.set_u32("no_explosion_timer", getGameTime() + 30);
		this.set_f32("factor", factor);
		this.set_u32("fuel_timer", getGameTime() + fuel_timer_max / factor);
		
		this.set_u16("controller_blob_netid", caller_netid);
		this.set_u16("controller_player_netid", player_netid);
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("CruiseMissile_Loop.ogg");
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundVolume(0.3f);
		sprite.SetEmitSoundPaused(false);
		sprite.PlaySound("CruiseMissile_Launch.ogg", 2.00f, 1.00f);
		
		this.SetLight(true);
		this.SetLightRadius(128.0f);
		this.SetLightColor(SColor(255, 255, 100, 0));
		
		if (isServer() && ply !is null)
		{
			this.server_SetPlayer(ply);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ controller = point.getOccupied();
	if (controller is null) return true;
	else return false;
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	for(int counter = 0; counter < 5; ++counter) {
		f32 speed_mod = this.getVelocity().Length();
		Vec2f offset = Vec2f(0, 16+XORRandom(speed_mod)-(speed_mod/2)).RotateBy(this.getAngleDegrees());
		CParticle@ p = ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 2.0f, 2 + XORRandom(3), -0.1f, false);
		if (p !is null) {
			p.growth = -0.05;
			p.setRenderStyle(RenderStyle::outline);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (customData == Hitters::fire)
	{
		return damage / 4;
	}

	return damage;
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string[] blobnames = 
	{
		"mat_mininuke",
		"mat_mustard",
		"mat_fuel",
		"mat_acid",
		"mat_clusterbomb",
		"mat_paxilon",
		"mat_rippio",
		"mat_methane",
		"mat_cocokbomb",
		"mat_dynamite",
		"mat_mithrilbomb",
		"mat_boof",
		"mat_crak",
		"firejob",
		"mat_incendiarybomb",
		"mat_dirtybomb",
		"mat_bunkerbuster",
		"mat_antimatter",
		"mat_explodium",
		"mat_mithrilenriched",
		"mat_stunbomb",
		"mat_smokegrenade",
		"mat_explonuke"
	};

	CSprite@ sprite = this.getSprite();
	string blobname = blob.getName();

	for (int i = 0; i < blobnames.length; i++)
	{
		if(isClient())
		{
			this.setInventoryName(blob.getInventoryName() + " Missile");
			if (blobname == blobnames[i])
			{
				sprite.SetFrameIndex(i + 1);
				this.SetInventoryIcon(sprite.getConsts().filename, i + 1, Vec2f(16, 32));
				//print("set frame to " + (i + 1));
				break;
			}
			if (blobname == "firework" || blobname == "patreonfirework")
			{
				sprite.SetFrameIndex(14);
				this.SetInventoryIcon(sprite.getConsts().filename, 14, Vec2f(16, 32));
			}
			if (blobname == "mat_gae")
			{
				sprite.SetFrameIndex(12);
				this.SetInventoryIcon(sprite.getConsts().filename, 12, Vec2f(16, 32));
			}
		}
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob )
{
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetFrameIndex(0);
		this.SetInventoryIcon(sprite.getConsts().filename, 0, Vec2f(16, 32));
		this.setInventoryName("Cruise Missile");
	}

	if (isServer())
	{
		if (this.hasTag("offblast") && blob.hasTag("explosive"))
		{
			blob.Tag("DoExplode");
			blob.server_Die();
		}
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !inventoryBlob.hasTag("player");
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || blob.getPlayer() is null) return;
	if (!blob.isMyPlayer()) return;

	int transparency = 255;
	u32 gt = getGameTime();
	u32 max = blob.get_u32("fuel_timer");
	f32 factor = blob.get_f32("factor");

	if (gt > max) gt = max;
	f32 percentage = Maths::Min(1.0f, f32(Maths::Min(max, max-gt) / f32(fuel_timer_max / factor)));

	Vec2f pos = getDriver().getScreenPosFromWorldPos(Vec2f_lerp(blob.getOldPosition(), blob.getPosition(), getInterpolationFactor())) + Vec2f(-22, 48);
	Vec2f dimension = Vec2f(42, 4);
	Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);

	GUI::DrawIconByName("$opaque_heatbar$", pos);
	GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(transparency, 59, 20, 6));
	GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(transparency, 148, 27, 27));
	GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(transparency, 183, 51, 51));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.hasTag("offblast")) return false;
	AttachmentPoint@ bomb_point = this.getAttachments().getAttachmentPointByName("BOMB");
	if (bomb_point !is null) {
		CBlob@ bomb = bomb_point.getOccupied();
		if (bomb !is null) return false;
	}
	
	return forBlob.getTeamNum() == this.getTeamNum();
}
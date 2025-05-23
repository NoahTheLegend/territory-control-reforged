// Script by Tflippy & Gingerbeard
#include "Hitters.as";
#include "HittersTC.as";
const u32 fuel_timer_max = 80 * 5;

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");

	this.Tag("explosive");
	this.Tag("heavy weight");
	this.Tag("cruisemissile");

	this.addCommandID("offblast");
	this.addCommandID("emote");

	this.set_u32("no_explosion_timer", 0);
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 5.0f);
	this.set_f32("max_velocity", 15.0f);

	AddIconToken("$opaque_heatbar$", "Entities/Industry/Drill/HeatBar.png", Vec2f(24, 6), 0);
	AddIconToken("$transparent_heatbar$", "Entities/Industry/Drill/HeatBar.png", Vec2f(24, 6), 1);

	this.set_u16("controller_blob_netid", 0);
	this.set_u16("controller_player_netid", 0);

	this.getShape().SetRotationsAllowed(true);
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
		"mat_bigbomb",
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

void onTick(CBlob@ this)
{
	// payload ignition
	if (this.getHealth() <= 0.0f || this.isKeyJustPressed(key_action1))
	{
		CInventory@ inv = this.getInventory();
		CBlob@ payload = inv.getItem(0);
		CBlob@ payload2 = inv.getItem(1);
		if (payload !is null)
		{
			//print("payload is " + payload.getName());
			Vec2f velocity = this.getVelocity();
			f32 angle = velocity.getAngleDegrees();
			f32 quantity = 100;
			// special payloads
			if (payload.getName() == "mat_smokegrenade")
			{
				if (isClient()) this.getSprite().PlaySound("gas_leak.ogg");
				for (int i = 0; i < (quantity / 2) ; i++)
				{
					if (isServer())
					{
						CBlob@ smoke = server_CreateBlob("smokegas", -1, this.getPosition());
						smoke.setVelocity(velocity + Vec2f(20 - XORRandom(40), 5 - XORRandom(10)).RotateByDegrees(angle));
						payload.server_Die();
					}
				}
			}
			if (payload.getName() == "mat_dynamite")
			{
				int amount = inv.getCount("mat_dynamite");
				for (int i = 0; i < amount ; i++)
				{
					if(isServer())
					{
						CBlob@ dynamite = server_CreateBlob("dynamite", this.getTeamNum(), this.getPosition());
						payload.server_Die();
					}
				}
			}
			if (payload.getName() == "mat_fuel")
			{
				u16 quantity = inv.getCount("mat_fuel");
				
				f32 strength = quantity / (payload.getMaxQuantity() * 2); // 0.0f - 1.0f strength;

			 	if(isServer())
			 	{
			 		CBlob@ thermo = server_CreateBlob("thermobaricexplosion", this.getTeamNum(), this.getPosition());
					if (thermo !is null)
					{
  	 					thermo.set_f32("boom_end", 320 * strength);
		 				thermo.set_u32("boom_delay", 15 - (5*strength));
					}
			 		payload.server_Die();
			 	}
			}
			if (payload.getName() == "fragmine")
			{
				payload.Tag("exploding");
			}
			else if (payload.getName() != "mat_bunkerbuster" && payload.getName() != "mat_mithrilbomb")
			{
				if (isServer()) 
				{
					// spawn new blob and delete inventory blob - should fix shite not detonating
					CBlob@ blob = server_CreateBlob(payload.getName(), this.getTeamNum(), this.getPosition());
					this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 50.0, Hitters::burn, true);
					payload.server_Die();
				}
			}
		}
	}
	if (this.hasTag("offblast"))
	{
		if (this.isAttached())
		{
			this.server_DetachFromAll();
		}

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

			//this.SetFacingLeft(false); //causes bugs with sprite for some odd reason

			this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.75f, 20.0f));
			this.set_Vec2f("direction", nDir);

			this.setAngleDegrees(-nDir.getAngleDegrees() + 90 + 180);
			this.setVelocity(-nDir * this.get_f32("velocity"));

			MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}
		else
		{
			this.setAngleDegrees(-this.getVelocity().Angle() + 90);
			//this.getSprite().SetEmitSoundPaused(true);

			if(isClient())
			{
				CSprite@ sprite = this.getSprite();
				f32 modifier = Maths::Max(0, this.getVelocity().y * 0.04f);
				sprite.SetEmitSound("Shell_Whistle.ogg");
				sprite.SetEmitSoundPaused(false);
				sprite.SetEmitSoundVolume(Maths::Max(0, modifier));
			}
		}

		if (this.isKeyJustPressed(key_action1) || this.getHealth() <= 0.0f)
		{
			if (isServer())
			{
				ResetPlayer(this);
				this.server_Die();
				return;
			}
		}
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob.hasTag("human") || inventoryBlob.getName() == "backpackblob")
	{
		if (inventoryBlob.isMyPlayer()) Sound::Play("NoAmmo");
		return false;
	}
	else return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if ((blob !is null ? !blob.isCollidable() || blob.hasTag("gas") : !solid)) return;
		if (blob !is null && (blob.hasTag("platform") || blob.hasTag("gas") || blob.getName() == "flame")) return;

		if (this.hasTag("offblast") && this.get_u32("no_explosion_timer") < getGameTime()) 
		{
			ResetPlayer(this);
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
		}

		this.server_Die();
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	if (this.hasTag("offblast")) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	if (caller.hasTag("uav") || caller.hasTag("cruisemissile")) return;

	CPlayer@ ply = caller.getPlayer();
	if (ply !is null)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(ply.getNetworkID());

		caller.CreateGenericButton(11, Vec2f(0.0f, -5.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("offblast"))
	{
		const u16 caller_netid = params.read_u16();
		const u16 player_netid = params.read_u16();

		CPlayer@ caller = getPlayerByNetworkId(caller_netid);
		CPlayer@ ply = getPlayerByNetworkId(player_netid);

		if (this.hasTag("offblast")) return;

		this.Tag("aerial");
		this.Tag("projectile");
		this.Tag("offblast");

		this.set_u32("no_explosion_timer", getGameTime() + 10);
		this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);

		this.set_u16("controller_blob_netid", caller_netid);
		this.set_u16("controller_player_netid", player_netid);

		if (isServer())
		{
			this.server_DetachFromAll();
			if (ply !is null)
				this.server_SetPlayer(ply);
		}

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("CruiseMissile_Loop.ogg");
			sprite.SetEmitSoundSpeed(1.0f);
			sprite.SetEmitSoundVolume(0.3f);
			sprite.SetEmitSoundPaused(false);
			sprite.PlaySound("CruiseMissile_Launch.ogg", 2.00f, 1.00f);

			this.SetLight(true);
			this.SetLightRadius(128.0f);
			this.SetLightColor(SColor(255, 255, 100, 0));
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

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == HittersTC::bullet_high_cal)
	{
		return damage *= 1.5f;
	}

	return damage;
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || blob.getPlayer() is null) return;
	if (!blob.isMyPlayer()) return;
	if (blob.get_u32("fuel_timer") == 0) return;

	int transparency = 255;
	u32 gt = getGameTime();
	u32 max = blob.get_u32("fuel_timer");
	if (gt > max) return;
	f32 percentage = Maths::Min(1.0f, f32(Maths::Min(max, max-gt) / f32(fuel_timer_max)));

	//Vec2f pos = blob.getScreenPos() + Vec2f(-22, 16);

	Vec2f pos = getDriver().getScreenPosFromWorldPos(Vec2f_lerp(blob.getOldPosition(), blob.getPosition(), getInterpolationFactor())) + Vec2f(-22, 48);
	Vec2f dimension = Vec2f(42, 4);
	Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);

	GUI::DrawIconByName("$opaque_heatbar$", pos);
	
	GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(transparency, 59, 20, 6));
	GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(transparency, 148, 27, 27));
	GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(transparency, 183, 51, 51));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum();
}

void onDie(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv !is null)
	{
		for (u8 i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ b = inv.getItem(i);
			if (b !is null && b.hasTag("explosive"))
			{
				b.server_PutOutInventory(this);
				b.Tag("DoExplode");
				b.server_Die();
			}
		}
	}
	if (this.getPlayer() !is null)
	{
		ResetPlayer(this);
	}
}
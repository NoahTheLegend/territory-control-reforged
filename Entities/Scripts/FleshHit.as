// Flesh hit

#include "Hitters.as";
#include "HittersTC.as";
#include "ArmorCommon.as";

const f32 armor_damage_mod = 0.5f;

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	this.addCommandID("sync_f32_armorhealth");
}

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

void onTick(CBlob@ this)
{
	if (!this.isAttached() && getGameTime() % 300 == 0 && !this.hasTag("no_invincible_removal")) this.Untag("invincible");
	if (isServer() && getGameTime()%15==0 && this.getName() != "hazmat" && this.getName() != "exosuit")
	{
		if (this.hasTag("combat chicken")) return;
		CBlob@ b = getBlobByName("info_dead");
		
		if (isServer() && b !is null)
		{
			CBlob@ r = getBlobByName("rain");
			if (r !is null)
			{
				if (r.hasTag("acidic rain") && XORRandom(15)==0)
				{
					if (getMap() !is null && !getMap().rayCastSolidNoBlobs(Vec2f(this.getPosition().x, 0), this.getPosition()))
						this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.125f, Hitters::burn);
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;

	switch (customData)
	{
		// TC		
		case HittersTC::bullet_low_cal:
		case HittersTC::bullet_high_cal:
		case HittersTC::shotgun:
			dmg *= 1.00f;
			break;
			
		case HittersTC::radiation:
			// dmg = Maths::Max((dmg * 2.00f) * (this.get_u8("radpilled") * 0.10f), 0);
			dmg *= Maths::Floor(2.00f / (1.00f + this.get_u8("radpilled") * 0.25f));
			break;
		// Vanilla
		case Hitters::builder:
			dmg *= 1.75f;
			break;

		case Hitters::spikes:
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 1.25f;
			break;

		case Hitters::drill:
		case Hitters::bomb_arrow:
		case Hitters::bomb:
			dmg *= 1.50f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
		case Hitters::crush:
			dmg *= 2.00f;
			break;

		case Hitters::cata_stones:
		case Hitters::flying: // boat ram
			dmg *= 4.00f;
			break;
		
		case Hitters::fire:
			dmg *= 2.75f;
			break;

		case Hitters::burn:
			dmg *= 2.50f;
			break;

	}

	if (isServer())
	{
		if (customData == HittersTC::radiation)
		{
			if (this.hasTag("human") && !this.hasTag("transformed") && this.getHealth() <= 0.125f && XORRandom(2) == 0)
			{
				CBlob@ man = server_CreateBlob("mithrilman", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) man.server_SetPlayer(this.getPlayer());
				this.Tag("transformed");
				this.server_Die();
			}
		}
	}
	
	if (this.hasTag("equipment support"))
	{
		bool isBullet = (
			customData == HittersTC::bullet_low_cal || customData == HittersTC::bullet_high_cal || 
			customData == HittersTC::shotgun || customData == HittersTC::railgun_lance);
		
		string headname = this.get_string("equipment_head");
		string torsoname = this.get_string("equipment_torso");
		string torso2name = this.get_string("equipment2_torso");
		string bootsname = this.get_string("equipment_boots");

		bool is_propesko = hitterBlob !is null && hitterBlob.hasTag("propesko_explosion") && customData == Hitters::explosion;
		f32 hit_angle = 0.0f;
		if (hitterBlob !is null)
		{
			Vec2f hit_dir = hitterBlob.getPosition() - this.getPosition();
			hit_dir.Normalize();
			hit_angle = 360 - hit_dir.Angle();
		}

		if (headname != "" && this.exists(headname+"_health"))
		{
			f32 armorMaxHealth = this.get_f32(headname+"_maxhealth");
			f32 min_armor_health = this.get_f32(headname+"_minhealth");
			if (armorMaxHealth == 0 || min_armor_health == 0)
			{
				SetArmorHealth(this, headname, armorMaxHealth, min_armor_health);
			}
			
			f32 ratio = 0.0f;
			bool cool_hat = headname == "stahlhelm";

			if ((headname == "militaryhelmet" || headname == "nvd"))
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;

					case HittersTC::bullet_low_cal:
					case HittersTC::shotgun:
						ratio = 0.15f;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.15f;
						break;

					default:
						ratio = 0.10f;
						break;
				}
			}
			else if (cool_hat)
			{
				f32 deity_power = this.get_f32("deity_power");
				u16 fakemax = 100;
				u32 genocidal_points = Maths::Min(deity_power / 100, fakemax);
				f32 additional_defense_percent = genocidal_points*0.001*5;
				
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;
						
					case HittersTC::bullet_low_cal:
					case HittersTC::shotgun:
						ratio = 0.50f+additional_defense_percent;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.50f+additional_defense_percent;
						break;

					default:
						ratio = 0.10f;
						break;
				}
			}
			else if (headname == "carbonhelmet")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;

					case Hitters::explosion:
					{
						ratio = 0.6f;
						if (is_propesko && hit_angle < 360-45 && hit_angle > 180+45)
						{
							ratio = 0;
							dmg *= 0.01f;
						}

						break;
					}
					case Hitters::sword:
					case Hitters::keg:
					case Hitters::mine:
					case Hitters::mine_special:
					case Hitters::bomb:
						ratio = 0.6f;
						break;

					case HittersTC::bullet_low_cal:
					case HittersTC::shotgun:
						ratio = 0.5f;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.4f;
						break;

					default:
						ratio = 0.10f;
						break;
				}
			}
			else if (headname == "scubagear" || headname == "bucket" || headname == "pumpkin" || headname == "minershelmet")
					ratio = 0.20f;
			
			if (!cool_hat) {
				f32 armorHealth = this.get_f32(headname+"_health");
				if (armorHealth < min_armor_health) armorHealth = min_armor_health;
				ratio *= armorHealth / armorMaxHealth;
				//print("helm "+armorHealth+" min "+min_armor_health +" max "+armorMaxHealth);
	
				this.sub_f32(headname+"_health", dmg * armor_damage_mod);
				if (this.get_f32(headname+"_health") < min_armor_health) this.set_f32(headname+"_health", min_armor_health);
				SyncArmorHealth(this, headname+"_health", this.get_f32(headname+"_health"));
			}

			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
			dmg = playerDamage;
		}
		if (torsoname != "" && this.exists(torsoname+"_health"))
		{
			f32 armorMaxHealth = this.get_f32(torsoname+"_maxhealth");
			f32 min_armor_health = this.get_f32(torsoname+"_minhealth");
			if (armorMaxHealth == 0 || min_armor_health == 0)
			{
				SetArmorHealth(this, torsoname, armorMaxHealth, min_armor_health);
			}
			f32 ratio = 0.0f;

			if (torsoname == "bulletproofvest")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;

					case HittersTC::bullet_low_cal:
						ratio = 0.35f;
						break;
						
					case HittersTC::shotgun:
					    ratio = 0.30f;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.30f;
						break;

					default:
						ratio = 0.20f;
						break;
				}
			}
			else if (torsoname == "carbonvest")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;
					
					case Hitters::explosion:
					{
						ratio = 0.5f;
						if (is_propesko &&
							((hit_angle > 180-45 && hit_angle < 180+45)
							|| (hit_angle > 360-45 && hit_angle <= 360)
							|| (hit_angle < 45 && hit_angle >= 0)))
						{
							ratio = 0;
							dmg *= 0.01f;
						}

						break;
					}
					case Hitters::sword:
					case Hitters::keg:
					case Hitters::mine:
					case Hitters::mine_special:
					case Hitters::bomb:
						ratio = 0.6f;
						break;

					case HittersTC::bullet_low_cal:
					case HittersTC::shotgun:
						ratio = 0.5f;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.4f;
						break;

					default:
						ratio = 0.10f;
						break;
				}
			}
			else if (torsoname == "keg")
			{
				if ((customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::explosion || 
					customData == Hitters::bomb || customData == Hitters::bomb_arrow) && this.get_f32("keg_explode") == 0.0f)
				{
					this.set_f32("keg_explode", getGameTime() + (30.0f * 1.0f));
					this.SetLightRadius(this.get_f32("explosive_radius") * 0.5f);
					this.getSprite().PlaySound("/Sparkle.ogg", 1.00f, 1.00f);
					this.getSprite().PlaySound("MigrantScream1.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					ratio = 1.0f;
				}
				else ratio = 0.45f;
			}

			f32 armorHealth = this.get_f32(torsoname+"_health");

			if (armorHealth < min_armor_health) armorHealth = min_armor_health;
			ratio *= armorHealth / armorMaxHealth;

			this.sub_f32(torsoname+"_health", dmg * armor_damage_mod);
			if (this.get_f32(torsoname+"_health") < min_armor_health) this.set_f32(torsoname+"_health", min_armor_health);
			SyncArmorHealth(this, torsoname+"_health", this.get_f32(torsoname+"_health"));
			//print("vest "+armorHealth+" min "+min_armor_health +" max "+armorMaxHealth);

			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
			dmg = playerDamage;
		}

		if (torso2name != "" && this.exists(torso2name+"_health"))
		{
			f32 armorMaxHealth = this.get_f32(torso2name+"_maxhealth");
			f32 min_armor_health = this.get_f32(torso2name+"_minhealth");
			if (armorMaxHealth == 0 || min_armor_health == 0)
			{
				SetArmorHealth(this, torso2name, armorMaxHealth, min_armor_health);
			}
			f32 ratio = 0.0f;

			if (torso2name == "bulletproofvest")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;

					case HittersTC::bullet_low_cal:
						ratio = 0.35f;
						break;
						
					case HittersTC::shotgun:	
						ratio = 0.30f;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.30f;
						break;

					default:
						ratio = 0.25f;
						break;
				}
			}
			else if (torso2name == "carbonvest")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;
					
					case Hitters::explosion:
					case Hitters::sword:
					case Hitters::keg:
					case Hitters::mine:
					case Hitters::mine_special:
					case Hitters::bomb:
						ratio = 0.6f;
						break;

					case HittersTC::bullet_low_cal:
					case HittersTC::shotgun:
						ratio = 0.5f;
						break;

					case HittersTC::bullet_high_cal:
					case HittersTC::railgun_lance:
						ratio = 0.4f;
						break;

					default:
						ratio = 0.10f;
						break;
				}
			}
			if (torso2name == "keg" && !isBullet && customData != HittersTC::radiation)
			{
				if ((customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::explosion || 
					customData == Hitters::bomb || customData == Hitters::bomb_arrow) && this.get_f32("keg_explode") == 0.0f)
				{
					this.set_f32("keg_explode", getGameTime() + (30.0f * 1.0f));
					this.SetLightRadius(this.get_f32("explosive_radius") * 0.5f);
					this.getSprite().PlaySound("/Sparkle.ogg", 1.00f, 1.00f);
					this.getSprite().PlaySound("MigrantScream1.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					ratio = 1.0f;
				}
				else ratio = 0.45f;
			}

			f32 armorHealth = this.get_f32(torso2name+"_health");

			if (armorHealth < min_armor_health) armorHealth = min_armor_health;
			ratio *= armorHealth / armorMaxHealth;

			this.sub_f32(torso2name+"_health", dmg * armor_damage_mod);
			if (this.get_f32(torso2name+"_health") < min_armor_health) this.set_f32(torso2name+"_health", min_armor_health);
			SyncArmorHealth(this, torso2name+"_health", this.get_f32(torso2name+"_health"));
			//print("vest2 "+armorHealth+" min "+min_armor_health +" max "+armorMaxHealth);

			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
			dmg = playerDamage;
		}

		if (bootsname != "" && this.exists(bootsname+"_health"))
		{
			f32 armorMaxHealth = this.get_f32(bootsname+"_maxhealth");
			f32 min_armor_health = this.get_f32(bootsname+"_minhealth");
			if (armorMaxHealth == 0 || min_armor_health == 0)
			{
				SetArmorHealth(this, bootsname, armorMaxHealth, min_armor_health);
			}
			f32 ratio = 0.0f;

			if (bootsname == "combatboots")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;

					case Hitters::fall:
					case Hitters::explosion:
						ratio = 0.30f;
						break;

					default: ratio = 0.15f;
						break;
				}
			}
			else if (bootsname == "carbonboots")
			{
				switch (customData)
				{
					case HittersTC::radiation:
						ratio = 1.0f;
						break;

					case Hitters::explosion:
					{
						ratio = 0.6f;
						if (is_propesko && hit_angle < 180-45 && hit_angle > 45)
						{
							ratio = 0;
							dmg *= 0.01f;
						}

						break;
					}

					default: ratio = 0.1f;
						break;
				}
			}
			f32 armorHealth =  this.get_f32(bootsname+"_health");

			if (armorHealth < min_armor_health) armorHealth = min_armor_health;
			ratio *= armorHealth / armorMaxHealth;

			this.sub_f32(bootsname+"_health", dmg * armor_damage_mod);
			if (this.get_f32(bootsname+"_health") < min_armor_health) this.set_f32(bootsname+"_health", min_armor_health);
			SyncArmorHealth(this, bootsname+"_health", this.get_f32(bootsname+"_health"));
			//print("boots "+armorHealth+" min "+min_armor_health +" max "+armorMaxHealth);

			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
			dmg = playerDamage;
		}
	}
	
	// if (this.get_f32("crak_effect") > 0) dmg *= 0.30f;
	this.Damage(dmg, hitterBlob);

	f32 gibHealth = getGibHealth(this);

	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		this.Tag("do gib");
		
		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}

void SyncArmorHealth(CBlob@ this, string prop, f32 hp)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_string(prop);
	params.write_f32(hp);
	this.SendCommand(this.getCommandID("sync_f32_armorhealth"), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync_f32_armorhealth"))
	{
		if (!isClient()) return;

		string prop;
		if (!params.saferead_string(prop))
		{
			warn("Failed to read 'prop' to sync in FleshHit.as");
			return;
		}

		f32 hp;
		if (!params.saferead_f32(hp))
		{
			warn("Failed to read 'hp' to sync in FleshHit.as");
			return;
		}

		this.set_f32(prop, hp);
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("do gib"))
	{
		f32 count = 2 + XORRandom(4);
		int frac = Maths::Min(250, this.getMass() / count) * 0.50f;
		f32 radius = this.getRadius();
		
		f32 explodium_amount = this.get_f32("propeskoed") * 0.50f / count;
		
		for (int i = 0; i < count; i++)
		{
			if (isClient())
			{
				this.getSprite().PlaySound("Pigger_Gore.ogg", 0.3f, 0.9f);
				ParticleBloodSplat(this.getPosition() + getRandomVelocity(0, radius, 360), true);
			}
		
			if (isServer())
			{
				Vec2f vel = Vec2f(XORRandom(4) - 2, -2 - XORRandom(4));
				
				if (explodium_amount > 0.00f)
				{
					CBlob@ blob = server_CreateBlob("mat_dangerousmeat", this.getTeamNum(), this.getPosition());
					blob.server_SetQuantity(1 + (frac * 0.60f + XORRandom(frac)));
					//blob.setVelocity(vel);
				}
				else
				{
					CBlob@ blob = server_CreateBlob("mat_meat", this.getTeamNum(), this.getPosition());

					if (blob !is null)
					{
						blob.server_SetQuantity(1 + (frac * 0.25f + XORRandom(frac)));
						if (this.hasTag("badger"))
							blob.server_SetQuantity(blob.getQuantity() * 0.25);
							
						blob.setVelocity(vel);
					}
				}
			}
		}
	}
}

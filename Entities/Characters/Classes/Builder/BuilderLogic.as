// Builder logic

#include "Hitters.as";
#include "Knocked.as";
#include "BuilderCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MakeMat.as";
#include "Help.as";
#include "Requirements.as"
#include "BuilderHittable.as";
#include "PlacementCommon.as";
//#include "LoaderUtilities.as";
#include "ParticleSparks.as";
#include "CustomBlocks.as";
#include "Survival_Structs.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage_slave = 0.25f;
const f32 hit_damage_peasant = 0.25f;
const f32 hit_damage = 0.5f;
const f32 hit_damage_engineer = 0.5f;

f32 getDamage(CBlob@ this)
{
	if (this.getName() == "builder")
	{
		return hit_damage_peasant;
	}
	else if (this.getName() == "slave")
	{
		return hit_damage_slave;
	}
	else if (this.getName() == "engineer")
	{
		return hit_damage_engineer;
	}

	return hit_damage;
}

void onInit(CBlob@ this)
{
	this.set_f32("pickaxe_distance", 10.0f);
	this.set_f32("gib health", -3.0f);
	
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("human");

	HitData hitdata;
	this.set("hitdata", hitdata);

	this.addCommandID("pickaxe");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	SetHelp(this, "help self action2", "builder", "$Pick$Dig/Chop  $KEY_HOLD$$RMB$", "", 3);

	if (!this.exists("mining_hardness"))
	{
		this.set_u8("mining_hardness", 2);
	}

	if (!this.exists("max_build_length")) this.set_f32("max_build_length", 4.00f);
	if (!this.exists("build delay")) this.set_u32("build delay", 4);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_u32("timer", 0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if (this.get_u8("deity_id") == 4 && this.get_u32("build delay") >= 4) // mason
	{
		this.set_u32("build delay", 3);
	}

	if (this.get_u32("timer") > 1) this.set_u32("timer", this.get_u32("timer") - 1);
	//attachment bug fixixing try
	if (getGameTime() % 30 == 0)
	{
		CBlob@ carriedb = this.getCarriedBlob();
		if (carriedb !is null)
		{
			Vec2f cpos = carriedb.getPosition();
			Vec2f mpos = this.getPosition();
			if (cpos.x - mpos.x <= -10.0f || cpos.x - mpos.x >= 10.0f) carriedb.setPosition(mpos);
			else if (cpos.y - mpos.y <= -10.0f || cpos.y - mpos.y >= 10.0f) carriedb.setPosition(mpos);
		}
	}

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	if (this.get_string("equipment_torso") != "" && this.get_string("equipment2_torso") != "")
	{
		moveVars.walkFactor *= 0.933f;
		moveVars.jumpFactor *= 0.975f;
	}

	if (this.hasTag("glued") && this.get_u32("timer") > 1)
	{
		moveVars.walkFactor *= 0.4f;
		moveVars.jumpFactor *= 0.5f;
	}

	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	// activate/throw
	if(ismyplayer)
	{
		Pickaxe(this);

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}

	// slow down walking
	if(this.isKeyPressed(key_action2) && !this.hasTag("noRMB"))
	{
		RunnerMoveVars@ moveVars;
		if(this.get("moveVars", @moveVars))
		{	
			moveVars.walkFactor = 0.85f;
			moveVars.jumpFactor = 0.65f;
		}
	}

	if(ismyplayer && (this.isKeyPressed(key_action1) && !this.hasTag("noLMB")) && !this.isKeyPressed(key_inventory)) //Don't let the builder place blocks if he/she is selecting which one to place
	{
		BlockCursor @bc;
		this.get("blockCursor", @bc);

		HitData@ hitdata;
		this.get("hitdata", @hitdata);
		hitdata.blobID = 0;
		hitdata.tilepos = bc.buildable ? bc.tileAimPos : Vec2f(-8, -8);
	}

	// get rid of the built item
	if(this.isKeyJustPressed(key_inventory) || this.isKeyJustPressed(key_pickup))
	{
		this.set_u8("buildblob", 255);
		this.set_TileType("buildtile", 0);

		CBlob@ blob = this.getCarriedBlob();
		if(blob !is null && blob.hasTag("temp blob"))
		{
			blob.Untag("temp blob");
			blob.server_Die();
		}
	}
	
	if (getGameTime() % 30 == 0)
	{
		int playerTeam = this.getTeamNum();
		if (playerTeam < 7)
		{
			TeamData@ team_data;
			GetTeamData(playerTeam, @team_data);	
			
			if (team_data != null)
			{
				u16 upkeep = team_data.upkeep;
				u16 upkeep_cap = team_data.upkeep_cap;
				f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
				
				if (upkeep_ratio <= UPKEEP_RATIO_BONUS_MINING)
				{
					this.set_f32("team_mining_multiplier", 1.00f);
				}
				else 
				{
					this.set_f32("team_mining_multiplier", 0.00f);
				}
			}
		}
	}
}

void SendHitCommand(CBlob@ this, CBlob@ blob, const Vec2f tilepos, const Vec2f attackVel, const f32 attack_power)
{
	CBitStream params;
	params.write_netid(blob is null? 0 : blob.getNetworkID());
	params.write_Vec2f(tilepos);
	params.write_Vec2f(attackVel);
	params.write_f32(attack_power);

	this.SendCommand(this.getCommandID("pickaxe"), params);
}

bool RecdHitCommand(CBlob@ this, CBitStream@ params)
{
	u16 blobID;
	Vec2f tilepos, attackVel;
	f32 attack_power;

	if(!params.saferead_netid(blobID))
		return false;
	if(!params.saferead_Vec2f(tilepos))
		return false;
	if(!params.saferead_Vec2f(attackVel))
		return false;
	if(!params.saferead_f32(attack_power))
		return false;

	if(blobID == 0)
	{
		CMap@ map = getMap();
		
		if(map !is null)
		{
			TileType tile = map.getTile(tilepos).type;
		
			if (map.getSectorAtPosition(tilepos, "no build") is null)
			{
				u8 mining_hardness = this.get_u8("mining_hardness");
				bool can_mine = true;
				
				if (mining_hardness < 3) // builder
				{
					if ((tile >= CMap::tile_plasteel && tile <= CMap::tile_plasteel_d14)
					|| (tile >= CMap::tile_bplasteel && tile <= CMap::tile_bplasteel_d14))
					{
						this.getSprite().PlaySound("/metal_stone.ogg");
						sparks(tilepos, 1, 1);
						can_mine = false;
					}
				}
				
				if (mining_hardness < 2) // peasant
				{
					if ((tile >= CMap::tile_iron && tile <= CMap::tile_iron_d8)
					|| (tile >= CMap::tile_reinforcedconcrete_d5 && tile <= CMap::tile_reinforcedconcrete_d15)
					|| (tile >= CMap::tile_biron && tile <= CMap::tile_biron_d8)
					|| (tile >= CMap::tile_titanium && tile <= CMap::tile_titanium_d7))
					{
						this.getSprite().PlaySound("/metal_stone.ogg");
						sparks(tilepos, 1, 1);
						can_mine = false;
					}
				}
				
				if (mining_hardness < 1) // slave
				{
					if ((tile >= CMap::tile_concrete && tile <= CMap::tile_concrete_d7) && XORRandom(10) != 0)
					{
						this.getSprite().PlaySound("build_wall2.ogg", 1.0f, 0.8f);
						can_mine = false;
					}
				}
				
				if (can_mine)
				{
					if (isServer())
					{
						this.server_HitMap(tilepos, attackVel, 1.0f, Hitters::builder);
					}
				}
			}
		}
	}
	else
	{
		CBlob@ blob = getBlobByNetworkID(blobID);
		if(blob !is null)
		{
			u8 mining_hardness = this.get_u8("mining_hardness");
			bool can_mine = true;
			
			if (mining_hardness < 2)
			{
				if (blob.getName() == "iron_door")
				{
					this.getSprite().PlaySound("/metal_stone.ogg");
					sparks(tilepos, 1, 1);
					can_mine = false;
				}
			}
			
			if (this.get_f32("babbyed") > 0)
			{
				can_mine = false;
				this.getSprite().PlaySound("launcher_boing" + XORRandom(2), 0.5f, 1.7f);
				if (this.isMyPlayer())
				{		
					ShakeScreen(16.0f, 12.00f, this.getPosition());
				}
			}
			
			if (can_mine)
			{
				const bool teamHurt = !blob.hasTag("flesh") || blob.hasTag("dead");
				if (isServer()) this.server_Hit(blob, tilepos, attackVel, attack_power, Hitters::builder, teamHurt);
			}
		}
	}

	return true;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("pickaxe"))
	{
		if(!RecdHitCommand(this, params))
			warn("error when recieving pickaxe command");
	}
}

//helper class to reduce function definition cancer
//and allow passing primitives &inout
class SortHitsParams
{
	Vec2f aimPos;
	Vec2f tilepos;
	Vec2f pos;
	bool justCheck;
	bool extra;
	bool hasHit;
	HitInfo@ bestinfo;
	f32 bestDistance;
};

void Pickaxe(CBlob@ this)
{
	HitData@ hitdata;
	CSprite @sprite = this.getSprite();
	bool strikeAnim = sprite.isAnimation("strike");

	if(!strikeAnim)
	{
		this.get("hitdata", @hitdata);
		hitdata.blobID = 0;
		hitdata.tilepos = Vec2f_zero;
		return;
	}

	// no damage cause we just check hit for cursor display
	bool justCheck = !sprite.isFrameIndex(hit_frame);
	bool adjusttime = sprite.getFrameIndex() < hit_frame - 1;

	// pickaxe!

	this.get("hitdata", @hitdata);

	if(hitdata is null) return;

	Vec2f blobPos = this.getPosition();
	Vec2f aimPos = this.getAimPos();
	Vec2f aimDir = aimPos - blobPos;

	// get tile surface for aiming at little static blobs
	Vec2f normal = aimDir;
	normal.Normalize();

	Vec2f attackVel = normal;

	if (!adjusttime)
	{
		if (!justCheck)
		{
			if (hitdata.blobID == 0)
			{
				SendHitCommand(this, null, hitdata.tilepos, attackVel, hit_damage);
			}
			else
			{
				CBlob@ b = getBlobByNetworkID(hitdata.blobID);
				if (b !is null)
				{
					SendHitCommand(this, b, (b.getPosition() + this.getPosition()) * 0.5f, attackVel, this.getName() == "builder" ? hit_damage : this.getName() == "slave" ? hit_damage_slave : hit_damage_engineer);
				}
			}
		}
		return;
	}

	hitdata.blobID = 0;
	hitdata.tilepos = Vec2f_zero;

	f32 arcdegrees = 90.0f;

	f32 aimangle = aimDir.Angle();
	Vec2f pos = blobPos - Vec2f(2, 0).RotateBy(-aimangle);
	f32 attack_distance = this.getRadius() + this.get_f32("pickaxe_distance");
	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;

	bool hasHit = false;

	const f32 tile_attack_distance = attack_distance * 1.5f;
	Vec2f tilepos = blobPos + normal * Maths::Min(aimDir.Length() - 1, tile_attack_distance);
	Vec2f surfacepos;
	map.rayCastSolid(blobPos, tilepos, surfacepos);

	Vec2f surfaceoff = (tilepos - surfacepos);
	f32 surfacedist = surfaceoff.Normalize();
	tilepos = (surfacepos + (surfaceoff * (map.tilesize * 0.5f)));

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@ bestinfo = null;
	f32 bestDistance = 100000.0f;

	HitInfo@[] hitInfos;

	//setup params for ferrying data in/out
	SortHitsParams@ hit_p = SortHitsParams();

	//copy in
	hit_p.aimPos = aimPos;
	hit_p.tilepos = tilepos;
	hit_p.pos = pos;
	hit_p.justCheck = justCheck;
	hit_p.extra = true;
	hit_p.hasHit = hasHit;
	@(hit_p.bestinfo) = bestinfo;
	hit_p.bestDistance = bestDistance;

	if (map.getHitInfosFromArc(pos, -aimangle, arcdegrees, attack_distance, this, @hitInfos))
	{
		f32 damage = getDamage(this);
		SortHits(this, hitInfos, damage, hit_p);
	}

	aimPos = hit_p.aimPos;
	tilepos = hit_p.tilepos;
	pos = hit_p.pos;
	justCheck = hit_p.justCheck;
	hasHit = hit_p.hasHit;
	@bestinfo = hit_p.bestinfo;
	bestDistance = hit_p.bestDistance;

	bool noBuildZone = map.getSectorAtPosition(tilepos, "no build") !is null;
	bool isgrass = false;

	if ((tilepos - aimPos).Length() < bestDistance && map.getBlobAtPosition(tilepos) is null)
	{
		Tile tile = map.getTile(surfacepos);

		if (!noBuildZone && !map.isTileGroundBack(tile.type))
		{
			//normal, honest to god tile
			if (map.isTileBackgroundNonEmpty(tile) || map.isTileSolid(tile))
			{
				hasHit = true;
				hitdata.tilepos = tilepos;
			}
			else if (map.isTileGrass(tile.type) || isTileSnowPile(tile.type))
			{
				//NOT hashit - check last for grass
				isgrass = true;
			}
		}
	}

	if (!hasHit)
	{
		//copy in
		hit_p.aimPos = aimPos;
		hit_p.tilepos = tilepos;
		hit_p.pos = pos;
		hit_p.justCheck = justCheck;
		hit_p.extra = false;
		hit_p.hasHit = hasHit;
		@(hit_p.bestinfo) = bestinfo;
		hit_p.bestDistance = bestDistance;

		//try to find another possible one
		if (bestinfo is null)
		{
			f32 damage = getDamage(this);
			SortHits(this, hitInfos, damage, hit_p);
		}

		//copy out
		aimPos = hit_p.aimPos;
		tilepos = hit_p.tilepos;
		pos = hit_p.pos;
		justCheck = hit_p.justCheck;
		hasHit = hit_p.hasHit;
		@bestinfo = hit_p.bestinfo;
		bestDistance = hit_p.bestDistance;

		//did we find one (or have one from before?)
		if (bestinfo !is null)
		{
			hitdata.blobID = bestinfo.blob.getNetworkID();
		}
	}

	if (isgrass && bestinfo is null)
	{
		hitdata.tilepos = tilepos;
	}
}

void SortHits(CBlob@ this, HitInfo@[]@ hitInfos, f32 damage, SortHitsParams@ p)
{
	//HitInfo objects are sorted, first come closest hits
	for (uint i = 0; i < hitInfos.length; i++)
	{
		HitInfo@ hi = hitInfos[i];

		CBlob@ b = hi.blob;
		if (b !is null) // blob
		{
			if (!canHit(this, b, p.tilepos, p.extra))
			{
				continue;
			}

			if (!p.justCheck && isUrgent(this, b))
			{
				p.hasHit = true;
				SendHitCommand(this, b, hi.hitpos, b.getPosition() - p.pos, damage);
			}
			else
			{
				bool never_ambig = neverHitAmbiguous(b);
				f32 len = never_ambig ? 1000.0f : (p.aimPos - b.getPosition()).Length();
				if (len < p.bestDistance)
				{
					if (!never_ambig)
						p.bestDistance = len;

					@(p.bestinfo) = hi;
				}
			}
		}
	}
}

bool ExtraQualifiers(CBlob@ this, CBlob@ b, Vec2f tpos)
{
	//urgent stuff gets a pass here
	if (isUrgent(this, b))
		return true;

	//check facing - can't hit stuff we're facing away from
	f32 dx = (this.getPosition().x - b.getPosition().x) * (this.isFacingLeft() ? 1 : -1);
	if (dx < 0)
		return false;

	//only hit static blobs if aiming directly at them
	CShape@ bshape = b.getShape();
	if (bshape.isStatic())
	{
		bool bigenough = bshape.getWidth() >= 8 &&
		                 bshape.getHeight() >= 8;

		if (bigenough)
		{
			if (!b.isPointInside(this.getAimPos()) && !b.isPointInside(tpos))
				return false;
		}
		else
		{
			Vec2f bpos = b.getPosition();
			//get centered on the tile it's positioned on (for offset blobs like spikes)
			Vec2f tileCenterPos = Vec2f(s32(bpos.x / 8), s32(bpos.y / 8)) * 8 + Vec2f(4, 4);
			f32 dist = Maths::Min((tileCenterPos - this.getAimPos()).LengthSquared(),
			                      (tileCenterPos - tpos).LengthSquared());
			if (dist > 25) //>5*5
				return false;
		}
	}

	return true;
}

bool neverHitAmbiguous(CBlob@ b)
{
	string name = b.getName();
	return name == "saw";
}

bool canHit(CBlob@ this, CBlob@ b, Vec2f tpos, bool extra = true)
{
	if(extra && !ExtraQualifiers(this, b, tpos))
	{
		return false;
	}

	if(b.hasTag("invincible"))
	{
		return false;
	}

	if(b.getTeamNum() == this.getTeamNum())
	{
		if(b.hasTag("dead"))
			return true;

		if(b.getName() == "mine")
			return false;

		if(b.hasTag("flesh") || b.hasTag("player"))
			return false;

		//static or background stuff
		CShape@ b_shape = b.getShape();
		if(!b.isCollidable() || (b_shape !is null && b_shape.isStatic()))
		{
			//maybe we shouldn't hit this.
			//check if we should always hit
			return BuilderAlwaysHit(b);
		}
	}
	else if(b.isAttached() && !b.hasTag("player"))
	{
		return false;
	}

	return true;
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	// ignore collision for built blob
	BuildBlock[][]@ blocks;
	if(!this.get("blocks", @blocks))
	{
		return;
	}

	const u8 PAGE = this.get_u8("build page");
	for(u8 i = 0; i < blocks[PAGE].length; i++)
	{
		BuildBlock@ block = blocks[PAGE][i];
		if(block !is null && block.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped(null);
			detached.IgnoreCollisionWhileOverlapped(null);
		}
	}

	// BUILD BLOB
	// take requirements from blob that is built and play sound
	// put out another one of the same
	if(detached.hasTag("temp blob"))
	{
		if(!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}

		uint i = this.get_u8("buildblob");
		if(i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if(b.name == detached.getName())
			{
				this.set_u8("buildblob", 255);
				this.set_TileType("buildtile", 0);

				CInventory@ inv = this.getInventory();

				CBitStream missing;
				if(hasRequirements(inv, b.reqs, missing))
				{
					server_TakeRequirements(inv, b.reqs);
				}
				// take out another one if in inventory
				server_BuildBlob(this, blocks[PAGE], i);
			}
		}
	}
	else if((this.isKeyPressed(key_action1) || this.isKeyJustPressed(key_action1)) && detached.getName() == "seed")
	{
		CBlob@ anotherBlob = this.getInventory().getItem(detached.getName());
		if(anotherBlob !is null)
		{
			this.server_Pickup(anotherBlob);
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	// destroy built blob if somehow they got into inventory
	if(blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}

	if(this.isMyPlayer() && blob.hasTag("material"))
	{
		SetHelp(this, "help inventory", "builder", "$Help_Block1$$Swap$$Help_Block2$           $KEY_HOLD$$KEY_F$", "", 3);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player=this.getPlayer();
	if(this.hasTag("invincible") || (player !is null && player.freeze)) {
		return 0;
	}
	return damage;
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	if (!isServer()) return;
	if (oldTeam < 7 && this.getTeamNum() >= 7)
	{
		if (this.getName() == "engineer")
		{
			CBlob@ newBlob = server_CreateBlob("builder",this.getTeamNum(),this.getPosition());
			if (newBlob !is null)
			{
				CInventory@ inv = this.getInventory();
				if (inv !is null)
				{
					this.MoveInventoryTo(newBlob);
				}

				if (this.getPlayer() !is null) newBlob.server_SetPlayer(this.getPlayer());
				this.server_Die();
			}
		}
	}
}
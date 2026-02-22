//Ghost logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"

void onInit(CBlob@ this)
{
	//this.Tag("noBubbles"); this is for disabling emoticons, we won't need that.
	//this.Tag("notarget"); //makes AI never target us
	//this.Tag("noCapturing");
	this.Tag("truesight");
	this.Tag("bomb_immune");

	//this.Tag("noUseMenu");
	this.set_f32("gib health", -3.0f);

	//this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().rotates = false;

	this.Tag("player");
	//this.Tag("invincible");
	//this.Tag("no_invincible_removal");

	CShape@ shape = this.getShape();
	shape.getConsts().net_threshold_multiplier = 0.5f;

	//this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	this.getSprite().SetAnimation("idle_fly");

	this.set_u8("rotation_mod", 1);
	this.set_bool("increment", true);
	this.set_f32("rotation", 0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		/*player.server_setTeamNum(-1);
		this.server_setTeamNum(-1);*/
		player.SetScoreboardVars("ScoreboardIcons.png", (this.getSexNum() == 0 ? 8 : 9), Vec2f(16, 16));
		//client_AddToChat(player.getUsername() + " has entered the " + (this.getSexNum() == 0 ? "Grandpa" : "Grandma") + " Administrator mode!", SColor(255, 255, 80, 150));
	}
}

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();

	//if (player !is null)
	//{
	//	// client_AddToChat(player.getUsername() + " is no longer in the Grandpa Administrator mode!", SColor(255, 255, 80, 150));
	//	client_AddToChat(player.getUsername() + " has left the " + (this.getSexNum() == 0 ? "Grandpa" : "Grandma") + " Administrator mode!", SColor(255, 255, 80, 150));
	//}

	ShakeScreen(64, 32, this.getPosition());
	if(!isClient()){return;}
	ParticleZombieLightning(this.getPosition());
	this.getSprite().PlaySound("SuddenGib.ogg", 0.9f, 1.0f);
}

void onTick(CBlob@ this)
{
	if (this.isKeyPressed(key_action1)) this.AddForce((this.getAimPos()-this.getPosition())*2);
	CSprite@ sprite = this.getSprite();
	CMap@ map = this.getMap();

	bool did_clip = this.getOldVelocity().Length()>10;
	bool clips = this.getVelocity().Length()>10;

	bool stops = did_clip && !clips;
	bool accelerates = !did_clip && clips;

	this.getShape().getConsts().mapCollisions = !clips;
	this.getShape().getConsts().collidable = !clips;

	if (stops)
	{
		//print("you need to goon mark");
	}

	f32 bomb_step_len = 4;

	for (int boom_step = 0; boom_step < this.getVelocity().Length()/bomb_step_len; ++boom_step)
	{

		Vec2f boom_pos = this.getPosition()+(Vec2f(1, 0)*bomb_step_len*boom_step).RotateBy(-this.getVelocity().AngleDegrees());
		if (clips && isServer())
		{
			if (getMap().isTileSolid(boom_pos) || (getMap().isTileBackground(getMap().getTile(boom_pos)) && XORRandom(100)<5))
			{
				CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
				if (boom !is null)
				{
					boom.setPosition(boom_pos);
					boom.set_u8("boom_start", 0);
					boom.set_u8("boom_end", 2);
					boom.set_u8("boom_frequency", 1);
					boom.set_u32("boom_delay", 0);
					boom.set_u32("flash_delay", 0);
					boom.Tag("no fallout");
					boom.Tag("no flash");
					boom.Tag("no mithril");
					// boom.Tag("no particles");
					// boom.Tag("no explosion particles");
					boom.set_string("custom_explosion_sound", "ShockMine_explode");
					boom.Init();
					boom.Tag("bomb_immune");
					boom.Tag("no force from explosion");
				}
			}
		}
	}

	if (map !is null)
	{
		if (this.getPosition().y > map.tilemapheight*8-24) this.AddForce(Vec2f(0, -1000.0f));
	}

	if (this.isKeyJustPressed(key_action2))
	{
		this.getSprite().PlaySound("omnicheeks.ogg");
		this.getSprite().SetAnimation("cheeks");
		this.set_u32("last_cheeks_anim_tick", getGameTime());
	}

	if ((getGameTime()-30)>this.get_u32("last_cheeks_anim_tick"))
	{
		if (this.getSprite().animation.name!="idle_fly")
		{
			this.getSprite().SetAnimation("idle_fly");
			this.getSprite().SetZ(800);
		}
	} else
	{
		this.getShape().getConsts().collidable = false;
		this.getShape().getConsts().mapCollisions = false;
		this.getSprite().SetZ(-10);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return Maths::Min(damage*0.01f, 0.1);
}

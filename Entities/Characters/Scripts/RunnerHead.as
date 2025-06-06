// generic character head script

// TODO: fix double includes properly, added the following line temporarily to fix include issues
#include "PaletteSwap.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"
#include "DeityCommon.as"

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

//handling Heads pack DLCs

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob !is null)
	{
		blob.addCommandID("reload_head");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isClient())
	{
		if (cmd == this.getCommandID("reload_head"))
		{
			ReloadHead(this.getSprite());
		}
	}
}

int getHeadsPackIndex(int headIndex)
{
	if (headIndex > 255) {
		if ((headIndex % 256) > NUM_UNIQUEHEADS) {
			return Maths::Min(getHeadsPackCount() - 1, Maths::Floor(headIndex / 255.0f));
		}
	}
	return 0;
}

bool doTeamColour(int packIndex)
{
	switch(packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

bool doSkinColour(int packIndex)
{
	switch(packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

int getHeadFrame(CBlob@ blob, int headIndex, bool default_pack = false)
{
	if(headIndex < NUM_UNIQUEHEADS)
	{
		return headIndex * NUM_HEADFRAMES;
	}

	//special heads logic for default heads pack
	if(default_pack && (headIndex == 255 || headIndex == NUM_UNIQUEHEADS))
	{
		CRules@ rules = getRules();
		bool holidayhead = false;
		if(rules !is null && rules.exists("holiday"))
		{
			const string HOLIDAY = rules.get_string("holiday");
			if(HOLIDAY == "Halloween")
			{
				headIndex = NUM_UNIQUEHEADS + 43;
				holidayhead = true;
			}
			else if(HOLIDAY == "Christmas")
			{
				headIndex = NUM_UNIQUEHEADS + 61;
				holidayhead = true;
			}
		}

		//if nothing special set
		if(!holidayhead)
		{
			string config = blob.getName();
			if(config == "builder")
			{
				headIndex = NUM_UNIQUEHEADS;
			}
			else if(config == "knight")
			{
				headIndex = NUM_UNIQUEHEADS + 1;
			}
			else if(config == "archer")
			{
				headIndex = NUM_UNIQUEHEADS + 2;
			}
			else if(config == "migrant")
			{
				Random _r(blob.getNetworkID());
				headIndex = 69 + _r.NextRanged(2); //head scarf or old
			}
			else
			{
				// default
				headIndex = NUM_UNIQUEHEADS;
			}
		}
	}

	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) +
	        (blob.getSexNum() == 0 ? 0 : 1)) * NUM_HEADFRAMES;
}

string getHeadTexture(int headIndex)
{
	return getHeadsPackByIndex(getHeadsPackIndex(headIndex)).filename;
}

void onPlayerInfoChanged(CSprite@ this)
{
	ReloadHead(this);
}

void ReloadHead(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CPlayer@ ply = blob.getPlayer();
	
	int head_index = blob.getHeadNum();
	
	if (ply !is null && blob !is null)
	{
		// Since he's evil
		if (ply.getUsername() == "Mithrios")
		{
			blob.Tag("mithrios");
		
			head_index = 101;
		}
		
		else if (ply.getUsername() == "PURPLExeno")
		{	
		
			head_index = 109;

		}
		
		else if (ply.getUsername() == "ZOMBICEK")
		{	
		
			head_index = 110;

		}
		
		else if (ply.getUsername() == "Killy07")
		{	
			head_index = 111;
		}
		
		else if (ply.getUsername() == "reqzites")
		{	
		
			head_index = 112;

		}

		else if (ply.getUsername() == "arsenpip")
		{
			head_index = 127;
		}

		else if (ply.getUsername() == "kusaka79")
		{
			head_index = 128;
		}
		
		else if (ply.getUsername() == "NoahTheLegend")
		{	
			head_index = 129;
		}
		
		else if (ply.getUsername() == "vladkvs193")
		{
			head_index = 130;
		}

		else if (ply.getUsername() == "Markoss")
		{	
			head_index = 122;
		}

		else if (ply.getUsername() == "Bohdanu")
		{	
			head_index = 123;
		}
		
		else if (ply.getUsername() == "cbryant21")
		{	
			head_index = 36;
		}
		
		else if (ply.getUsername() == "FrankStain")
		{	
			head_index = 116;
		}
		
		else if (ply.getUsername() == "GoldenGuy")
		{	
			head_index = 118;
		}
		
		else if (ply.getUsername() == "strangelizard")
		{	
			head_index = 126;
		}
		
		u8 deity_id = blob.get_u8("deity_id");
		switch (deity_id)
		{
			case Deity::mithrios:
			{
				head_index = 101;
			}
			break;
			
			case Deity::ivan:
			{
				head_index = 104;
			}
			
			case Deity::cocok:
			{
				head_index = 105;
			}

			case Deity::mason:
			{
				if (ply.getUsername() == "cbryant21")
					head_index = 115;
			}

			break;
		}
	}
	
	//LoadHead(this, (blob.exists("override head") ? blob.get_u8("override head") : blob.getHeadNum()));
	if(blob.exists("override head"))
	{
		LoadHead(this, blob.get_u8("override head"));
	}
	else
	{
		LoadHead(this, head_index);
	}
}

CSpriteLayer@ LoadHead(CSprite@ this, int headIndex)
{
	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	// strip old head
	this.RemoveSpriteLayer("head");

	// get dlc pack info
	int headsPackIndex = getHeadsPackIndex(headIndex);
	HeadsPack@ pack = getHeadsPackByIndex(headsPackIndex);
	string texture_file = pack.filename;

	bool override_frame = false;

	//(has default head set)
	bool defaultHead = (headIndex == 255 || headIndex == NUM_UNIQUEHEADS);
	if(defaultHead)
	{
		//accolade custom head handling
		//todo: consider pulling other custom head stuff out to here
		CPlayer@ p = blob.getPlayer();
		if (p !is null && !p.isBot())
		{
			Accolades@ acc = getPlayerAccolades(p.getUsername());
			if (acc.hasCustomHead())
			{
				texture_file = "Sprites/" + acc.customHeadTexture + ".png";
				headIndex = acc.customHeadIndex;
				headsPackIndex = 0;
				override_frame = true;
			}
		}
	}
	else
	{
		//not default head; do not use accolades data
	}

	//add new head
	int team = doTeamColour(headsPackIndex) ? blob.getTeamNum() : 0;
	int skin = doSkinColour(headsPackIndex) ? blob.getSkinNum() : 0;

	//add new head
	CSpriteLayer@ head = this.addSpriteLayer("head", texture_file, 16, 16, team, skin);

	//
	headIndex = headIndex % 256; // wrap DLC heads into "pack space"

	// figure out head frame
	s32 headFrame = override_frame ?
		(headIndex * NUM_HEADFRAMES) :
		getHeadFrame(blob, headIndex, headsPackIndex == 0);

	if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(headFrame);
		anim.AddFrame(headFrame + 1);
		anim.AddFrame(headFrame + 2);
		head.SetAnimation(anim);

		head.SetFacingLeft(blob.isFacingLeft());
	}

	//setup gib properties
	blob.set_s32("head index", headFrame);
	blob.set_string("head texture", texture_file);
	blob.set_s32("head team", team);
	blob.set_s32("head skin", skin);

	return head;
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	if (blob !is null && blob.getName() != "bed")
	{
		int frame = blob.get_s32("head index");
		int framex = frame % FRAMES_WIDTH;
		int framey = frame / FRAMES_WIDTH;

		Vec2f pos = blob.getPosition();
		Vec2f vel = blob.getVelocity();
		f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.5;
		if(isClient()){
			makeGibParticle(
				blob.get_string("head texture"),
				pos, vel + getRandomVelocity(90, hp , 30),
				framex, framey, Vec2f(16, 16),
				2.0f, 20, "/BodyGibFall", blob.getTeamNum()
			);
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	ScriptData@ script = this.getCurrentScript();
	if (script is null)
		return;

	if (blob.getShape().isStatic())
	{
		script.tickFrequency = 60;
	}
	else
	{
		script.tickFrequency = 1;
	}


	// head animations
	CSpriteLayer@ head = this.getSpriteLayer("head");

	// load head when player is set or it is AI
	if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}

	if (head !is null)
	{
		Vec2f offset;

		// pixeloffset from script
		// set the head offset and Z value according to the pink/yellow pixels
		int layer = 0;
		Vec2f head_offset = getHeadOffset(blob, -1, layer);

		// behind, in front or not drawn
		if (layer == 0)
		{
			head.SetVisible(false);
		}
		else
		{
			head.SetVisible(this.isVisible());
			head.SetRelativeZ(layer * 0.25f);
		}

		offset = head_offset;

		// set the proper offset
		Vec2f headoffset(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
		headoffset += this.getOffset();
		headoffset += Vec2f(-offset.x, offset.y);
		headoffset += Vec2f(0, -2);
		head.SetOffset(headoffset);

		if (blob.hasTag("dead") || blob.hasTag("dead head"))
		{
			head.animation.frame = 2;

			// sparkle blood if cut throat
			if (isClient() && getGameTime() % 2 == 0 && blob.hasTag("cutthroat"))
			{
				Vec2f vel = getRandomVelocity(90.0f, 1.3f * 0.1f * XORRandom(40), 2.0f);
				ParticleBlood(blob.getPosition() + Vec2f(this.isFacingLeft() ? headoffset.x : -headoffset.x, headoffset.y), vel, SColor(255, 126, 0, 0));
				if (XORRandom(100) == 0)
					blob.Untag("cutthroat");
			}
		}
		else if (blob.hasTag("attack head"))
		{
			head.animation.frame = 1;
		}
		else
		{
			head.animation.frame = 0;
		}
	}
}

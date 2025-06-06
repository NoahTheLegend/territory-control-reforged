#include "HittersTC.as";
#include "RunnerCommon.as"

string[] firstnames = 
{ 
	"Jerry",
	"Bobby",
	"Harry",
	"Barry",
	"Garry",
	"Polly",
	"Fug",
	"Tweety",
	"Fleet",
};

string[] surnames = 
{ 
	"Eggbert",
	"Bobton",
	"Paxton",
	"Fughorn",
	"Egghorn",
	"Jaxton",
	"Barlington",
	"Bolton",
	"Bigglesworth",
	"Fugton"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = firstnames[rand.NextRanged(firstnames.length)] + " " + surnames[rand.NextRanged(surnames.length)];

	this.set_f32("gib health", -1.50f);
	if (!this.exists("voice pitch")) this.set_f32("voice pitch", 1.50f);
	this.set_string("chicken name", name);
	this.setInventoryName(name);

	if (this.hasTag("parachute")) this.AddScript("parachutepack_effect.as");

	this.Tag("dangerous");
	this.Tag("chicken");
	this.Tag("ignore saw");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isServer())
	{
		if (customData == HittersTC::radiation)
		{
			if (!this.hasTag("transformed") && this.getHealth() <= 0.125f && XORRandom(3) == 0)
			{
				CBlob@ blob = server_CreateBlob("cuck", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());
				this.Tag("transformed");
				this.server_Die();
			}
		}
		
		CBrain@ brain = this.getBrain();
		if (brain !is null && hitterBlob !is null)
		{
			CPlayer@ hitterPlayer = hitterBlob.getDamageOwnerPlayer();
			if (hitterPlayer !is null)
			{
				CBlob@ playerBlob = hitterPlayer.getBlob();
				if (playerBlob !is null) @hitterBlob = playerBlob;
			}
			
			if (hitterBlob.isCollidable() && hitterBlob.getTeamNum() != this.getTeamNum() && !hitterBlob.hasTag("material"))
			{
				if (brain.getTarget() is null) brain.SetTarget(hitterBlob);
				else if (!hitterBlob.hasTag("material")) brain.SetTarget(hitterBlob);
			}
		}
	}

	return damage;
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		if (getGameTime()%90==0)
		{
			if (this.getHealth() + 0.25f >= this.getInitialHealth())
			{
				this.server_SetHealth(this.getInitialHealth());
			}
			else this.server_Heal(0.25f);
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	if (!isServer()) return;
	if (attached !is null && attached.hasTag("weapon") && this.getPlayer() is null)
	{
		attached.Tag("fakeweapon");
	}
}

void onDetach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	if (!isServer()) return;
	if (attached !is null && attached.hasTag("fakeweapon") && this.getPlayer() is null)
	{
		attached.server_Die();
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (!isServer()) return;
	if (blob.hasTag("fakeweapon")) blob.server_Die();
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	this.Untag("ignore saw");
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null) carried.Untag("fakeweapon");
}
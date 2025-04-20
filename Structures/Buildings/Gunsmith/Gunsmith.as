// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

const string[] resources =
{
	"mat_pistolammo",
	"mat_rifleammo",
	"mat_shotgunammo",
	"mat_sniperammo",
	"mat_gatlingammo"
};

const u8[] resourceYields =
{
	10,
	8,
	4,
	1,
	15
};
#include "BulletTralls.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("extractable");
	this.Tag("change team on fort capture");

	this.getCurrentScript().tickFrequency = 300;
	this.inventoryButtonPos = Vec2f(-8, 0);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(7, 6));
	this.set_string("shop description", "Gunsmith's Workshop");
	this.set_u8("shop icon", 15);

	AddIconToken("$dp27$", "DP-27.png", Vec2f(32, 12), this.getTeamNum());
	AddIconToken("$icon_sniperammo$", "AmmoIcon_Sniper.png", Vec2f(24,24), 255);

	{
		ShopItem@ s = addShopItem(this, "Low Caliber Ammunition (20)", "$icon_pistolammo$", "mat_pistolammo-20", "Bullets for pistols and SMGs.");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Revolver", "$revolver$", "revolver", "A compact firearm for those with small pockets.\n\nUses Lowcal Rounds.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bobby Gun", "$smg$", "smg", "A submachine gun.\n\nUses Lowcal Rounds.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "PPSH", "$ppsh$", "ppsh", "WW2 most-used russian weapon.\n\nUses Lowcal Rounds.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High Caliber Ammunition (10)", "$icon_rifleammo$", "mat_rifleammo-10", "Bullets for rifles. Effective against armored targets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 60);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bolt Action Rifle", "$rifle$", "rifle", "A handy bolt action rifle.\n\nUses Highcal Rounds.");
		AddRequirement(s.requirements, "coin", "", "Coins", 200);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Lever Action Rifle", "$leverrifle$", "leverrifle", "A speedy lever action rifle.\n\nUses Highcal Rounds.");
		AddRequirement(s.requirements, "coin", "", "Coins", 300);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{	
		ShopItem@ s = addShopItem(this, "Sniper Rifle Dragunova", "$svd$", "svd", "A strong semi-auto sniper rifle.\n\nUses High Power Rounds.");
		AddRequirement(s.requirements, "blob",  "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 8);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 8);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun Shells (4)", "$icon_shotgunammo$", "mat_shotgunammo-4", "Shotgun Shells for... Shotguns.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Boomstick", "$icon_boomstick$", "boomstick", "You see this? A boomstick! The twelve-gauge double-barreled Bobington.\n\nUses Shotgun Shells.");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun", "$icon_shotgun$", "shotgun", "A short-ranged weapon that deals devastating damage.\n\nUses Shotgun Shells.");
		AddRequirement(s.requirements, "coin", "", "Coins", 350); 

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Scorcher", "$icon_flamethrower$", "flamethrower", "A tool used for incinerating plants, buildings and people.\n\nUses Oil.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 32);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 12);
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Machine Gun Ammunition (50)", "$icon_gatlingammo$", "mat_gatlingammo-50", "Ammunition used by the machine gun.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "DP-27", "$dp27$", "dp27", "A cheap machinegun that was primary used in WW2 by russians.\n\nUses Gatling Ammo.");
		AddRequirement(s.requirements, "coin", "", "Coins", 800); //1000c

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Brand-new AK", "$bnak$", "bnak", "Popular russian weapon.\n\nUses Highcal Rounds.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 12);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Acidthrower", "$icon_acidthrower$", "acidthrower", "A tool used for dissolving plants, buildings and people.\n\nUses Acid.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 12);
		AddRequirement(s.requirements, "coin", "", "Coins", 1250);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High Power Ammunition (10)", "$icon_sniperammo$", "mat_sniperammo-10", "Rounds that are mainly used by sniper rifles. Very effective against heavy armored targets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 120);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Big iron", "$truerevolver$", "truerevolver", "If a cowboy wants a cool handgun - he gets it no matter what.\n\nUses High Power Rounds.");
		AddRequirement(s.requirements, "coin", "", "Coins", 750);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gauss Rifle", "$icon_gaussrifle$", "gaussrifle", "A modified toy used to kill people.\n\nUses Steel Ingots.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 12);
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "L.O.L. Warhead Launcher", "$icon_mininukelauncher$", "mininukelauncher", "Are people bullying you again? Remember, there still is the nuclear option.\n\nUses L.O.L. or K.E.K. Warheads.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 20);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Small Rocket (1)", "$icon_smallrocket$", "mat_smallrocket-1", "Self-propelled ammunition for rocket launchers.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bazooka", "$icon_bazooka$", "bazooka", "A long tube capable of shooting rockets. Make sure nobody is standing behind it.\n\nUses Small Rockets.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 12);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade Launcher M79", "$icon_grenadelauncher$", "grenadelauncher", "A short-ranged weapon that launches grenades.\n\nUses Grenades.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 16);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 350);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Blazethrower", "$icon_blazethrower$", "blazethrower", "A Scorcher modification providing support for gaseous fuels.\n\nUses Fuel.");
		AddRequirement(s.requirements, "blob", "flamethrower", "Scorcher", 1);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 12);
		AddRequirement(s.requirements, "blob", "illegalgunpart", "Illegal Gun Part", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);

		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if(isServer())
	{
		u8 index = XORRandom(resources.length);

		if (!this.getInventory().isFull())
		{
			MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getName() == "extractor" || (forBlob.isOverlapping(this) && forBlob.getCarriedBlob() is null);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	CBlob@ carried = caller.getCarriedBlob();

	if (isInventoryAccessible(this, caller))
	{
		this.set_Vec2f("shop offset", Vec2f(4, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				MakeMat(callerBlob, this.getPosition(), spl[0], parseInt(spl[1]));
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}

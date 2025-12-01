// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "ArmorCommon.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	AddIconToken("$str$", "StoreAll.png", Vec2f(16, 16), 0);

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("remote_storage");
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	this.getCurrentScript().tickFrequency = 300;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.inventoryButtonPos = Vec2f(-8, 0);
	this.addCommandID("sv_store");
	this.addCommandID("make sound");
	this.addCommandID("make sound1");

	addTokens(this); //colored shop icons

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Armory");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Combat Helmet", "$icon_militaryhelmet$", "militaryhelmet", "A light combat helmet.\nCheap and practical. Good against all bullets.\n\nOccupies the Head slot");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Helmet", "$icon_militaryhelmet$", "repair_head_steel", "Repair combat helmet.");
		AddRequirement(s.requirements, "has armor", "militaryhelmet", "Military Helmet", 0);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Carbon Helmet", "$icon_carbonhelmet$", "carbonhelmet", "A heavy combat helmet.\nVery durable. Good against low caliber bullets and explosions,\nbut worse against high caliber and power rounds.\n\nOccupies the Head slot");
		AddRequirement(s.requirements, "blob", "mat_carbon", "Carbon", 60);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Carbon Helmet", "$icon_carbonhelmet$", "repair_head_carbon", "Repair carbon helmet.");
		AddRequirement(s.requirements, "has armor", "carbonhelmet", "Carbon Helmet", 0);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Backpack", "$icon_backpack$", "backpack", "A large leather backpack that can be equipped and used as an inventory.\nOccupies the Torso slot");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ballistic Vest", "$icon_bulletproofvest$", "bulletproofvest", "A resilient ballistic armor.\nCheap and practical. Good against all bullets.\n\nOccupies the Torso slot");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 4);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Vest", "$icon_bulletproofvest$", "repair_body_steel", "Repair ballistic vest.");
		AddRequirement(s.requirements, "has armor", "bulletproofvest", "Ballistic Vest", 0);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Carbon Vest", "$icon_carbonvest$", "carbonvest", "A heavy combat vest.\nVery durable. Good against low caliber bullets and explosions,\nbut worse against high caliber and power rounds.\n\nOccupies the Torso slot");
		AddRequirement(s.requirements, "blob", "mat_carbon", "Carbon", 70);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Carbon Vest", "$icon_carbonvest$", "repair_body_carbon", "Repair carbon vest.");
		AddRequirement(s.requirements, "has armor", "carbonvest", "Carbon vest", 0);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Parachute Pack", "$icon_parachute$", "parachutepack", "A piece of fabric to let you fall slowly.\nPress [E] while falling to activate.\n\nOccupies the Torso slot.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Combat Boots", "$icon_combatboots$", "combatboots", "A pair of light military boots.\nSlightly protects against all bullets and increases your mobility.\nModerately decreases fall damage.\nIncreases stomp damage.\n\nOccupies the Boots slot");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Boots", "$icon_combatboots$", "repair_boots_steel", "Repair combat boots.");
		AddRequirement(s.requirements, "has armor", "combatboots", "Combat Boots", 0);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Carbon Boots", "$icon_carbonboots$", "carbonboots", "A pair of heavy and sturdy boots.\nSlightly protects you against all bullets and explosions.\nSlightly increases running speed and fall damage.\n\nOccupies the Boots slot");
		AddRequirement(s.requirements, "blob", "mat_carbon", "Carbon", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Carbon Boots", "$icon_carbonboots$", "repair_boots_carbon", "Repair carbon boots.");
		AddRequirement(s.requirements, "has armor", "carbonboots", "Carbon Boots", 0);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Rendezook", "$icon_rendezook$", "rendezook", "A replica of a rocket launcher found behind the UPF shop in a trash can.\nDoes not seem to hurt anybody.");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Royal Guard Armor", "$icon_royalarmor$", "royalarmor", "A heavy armor that offers high damage resistance at cost of low mobility. Has a shield which is tough enough to block bullets.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 8);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Crossbow", "$crossbow$", "crossbow", "A hand-made ranged weapon.\nUses arrows to shoot.\nYou can set arrow type while holding different arrows near it.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Arrows (30)", "$mat_arrows$", "mat_arrows-30", "Arrows for crossbows.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrow (2)", "$mat_firearrows$", "mat_firearrows-2", descriptions[32], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrow (2)", "$mat_waterarrows$", "mat_waterarrows-2", descriptions[50], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	// reset shop colors
	addTokens(this);
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$icon_parachute$", "Parachutepack.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$jumpshoes$", "JumpShoes.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$icon_royalarmor$", "RoyalArmor.png", Vec2f(16, 8), 0, teamnum);
	AddIconToken("$icon_suitofarmor$", "SuitOfArmor.png", Vec2f(16, 16), 0, teamnum);
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("weapon") || blob.hasTag("ammo") || blob.hasTag("armor");
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;

	CBlob@[] blobs;
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(128, 96), this.getPosition() + Vec2f(-128, -96), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];

			if ((canPickup(blob)) && !blob.isAttached())
			{
				if (isClient() && this.getInventory().canPutItem(blob)) blob.getSprite().PlaySound("/PutInInventory.ogg");
				if (isServer()) this.server_PutInInventory(blob);
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (forBlob is null || this is null) return false;
	CBlob@ carried = forBlob.getCarriedBlob();
	return forBlob.isOverlapping(this) && (carried is null ? true : canPickup(carried));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	if (isInventoryAccessible(this, caller))
	{
		this.set_Vec2f("shop offset", Vec2f(8, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
}

const int[] costs = {75,150,50,250,250,150,500,500,500};
const string[] repair_blobnames = {"militaryhelmet", "bulletproofvest", "combatboots", "carbonhelmet", "carbonvest", "carbonboots"};

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("make sound")) this.getSprite().PlaySound("NoAmmo");
	if (cmd == this.getCommandID("make sound1")) this.getSprite().PlaySound("ConstructShort");
	if (cmd == this.getCommandID("shop made item"))
	{
		//this.getSprite().PlaySound("ConstructShort");
		
		u16 caller, item;

		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");
			string[] spll = name.split("_"); 
			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				getRules().set_u32(callerPlayer.getUsername()+"coins",getRules().get_u32(callerPlayer.getUsername()+"coins") +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1 && spl.length > 1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				this.SendCommand(this.getCommandID("make sound1"));
				MakeMat(callerBlob, this.getPosition(), spl[0], parseInt(spl[1]));

				// CBlob@ mat = server_CreateBlob(spl[0]);

				// if (mat !is null)
				// {
					// mat.Tag("do not set materials");
					// mat.server_SetQuantity(parseInt(spl[1]));
					// if (!callerBlob.server_PutInInventory(mat))
					// {
						// mat.setPosition(callerBlob.getPosition());
					// }
				// }
			}
			else
			{
				string blobName = spl[0];
				
				if (spll[0] == "repair")
				{	
					int type;
					int armor;
					int cost_coins;
					string blob_name;
					CBitStream reqs, missing;

					type = spll[1] == "head" ? 0 : spll[1] == "body" ? 1 : 2;
					armor = spll[2] == "steel" ? 0 : spll[2] == "carbon" ? 1 : 0;
					cost_coins = costs[type + 3*armor];
					blob_name = repair_blobnames[type+3*armor];

					if (callerBlob.get_f32(blob_name+"_health") != 0)
					{
						AddRequirement(reqs, "coin", "", "Coins", cost_coins);
						if (hasRequirements(callerBlob.getInventory(), reqs, missing))
						{
							server_TakeRequirements(callerBlob.getInventory(), reqs);
							this.SendCommand(this.getCommandID("make sound1"));
							
							f32 max_hp, min_hp;
							SetArmorHealth(this, blob_name, max_hp, min_hp);

							callerBlob.set_f32(blob_name+"_health", max_hp);
							callerBlob.Sync(blob_name+"_health", true);
							return;
						}
					}	

					if (callerBlob.getInventory().getItem(blob_name) !is null) 
					{
						CBlob@ item_blob = callerBlob.getInventory().getItem(blob_name);
						if (item_blob.get_f32("health") != 0)
						{
							AddRequirement(reqs, "coin", "", "Coins", cost_coins);	
							if (hasRequirements(callerBlob.getInventory(), reqs, missing))
							{
								server_TakeRequirements(callerBlob.getInventory(),reqs);
								this.SendCommand(this.getCommandID("make sound1"));
								item_blob.set_f32("health", 0);
								return;
							}			
							else this.SendCommand(this.getCommandID("make sound"));
						}
						else 
						{
							this.SendCommand(this.getCommandID("make sound"));
							return;				
						}
					}
					
					AddRequirement(reqs, "blob", blob_name, blob_name, 1);
					AddRequirement(reqs, "coin", "", "Coins", cost_coins);
					if (hasRequirements(callerBlob.getInventory(), reqs, missing))
					{
						server_TakeRequirements(callerBlob.getInventory(),reqs);
						this.SendCommand(this.getCommandID("make sound1"));
						blobName = blob_name;
						//this.getSprite().PlaySound("ConstructShort");
					}
					else 
					{
						this.SendCommand(this.getCommandID("make sound")); //Sound::Play("NoAmmo.ogg");
						return;
					}
				}
				
				bool mask = false;
				if (blobName == "bushyhelm")
				{
					blobName = "militaryhelmet";
					mask = true;
				}

				this.SendCommand(this.getCommandID("make sound1"));
				CBlob@ blob = server_CreateBlob(blobName, callerBlob.getTeamNum(), this.getPosition());
				if (mask) blob.Tag("bushy");

				if (blob is null && callerBlob is null) return;

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
	if (cmd == this.getCommandID("sv_store"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (isServer())
		{
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getName() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				if (inv !is null)
				{
					for (int i = 0; i < inv.getItemsCount(); i++)
					{
						CBlob @item = inv.getItem(i);
						if (canPickup(item))
						{
							caller.server_PutOutInventory(item);
							this.server_PutInInventory(item);
							i--;
						}
					}
				}
			}
		}

		if (caller !is null && caller.isMyPlayer())
		{
			caller.ClearButtons();
			caller.ClearGridMenus();
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	if (forBlob is null) return;
	if (forBlob.getControls() is null) return;
	Vec2f mscpos = forBlob.getControls().getMouseScreenPos(); 

	Vec2f MENU_POS = mscpos+Vec2f(-200,-96);
	CGridMenu@ sv = CreateGridMenu(MENU_POS, this, Vec2f(1, 1), "Store ");
	
	CBitStream params;
	params.write_u16(forBlob.getNetworkID());
	CGridButton@ store = sv.AddButton("$str$", "Store ", this.getCommandID("sv_store"), Vec2f(1, 1), params);
}
#include "MakeMat.as";
#include "Requirements.as";
#include "Skemlib.as";

const u16 max_loop = 150; // what you get for breaking it
const Vec2f SIGN_OFFSET(0, -4);
const f32 SCALE_FACTOR = 1.0f;

void onInit(CSprite@ this)
{
	this.SetZ(-50);
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 5;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
	
	this.set_u32("compactor_quantity", 0);
	this.set_string("compactor_resource", "");
	this.set_string("compactor_resource_name", "");
	
	this.addCommandID("compactor_withdraw");
	this.addCommandID("compactor_sync");
	
	AddSignLayerFrom(this.getSprite());
}

void AddSignLayerFrom(CSprite@ this)
{
	RemoveSignLayer(this);

	CBlob@ blob = this.getBlob();

	int team = blob.getTeamNum();
	int skin = blob.getSkinNum();

	int rot = 0;
	if (blob.exists("rot")) {
		rot = blob.get_f32("rot");
	}
	else {
		rot = 15 - XORRandom(30);
		if (Maths::Abs(rot)<3)
			rot = 0;
		blob.set_f32("rot", rot);
	}

	CSpriteLayer@ sign = this.addSpriteLayer("sign", "Factory.png" , 32, 16, team, skin);
	{
		Animation@ anim = sign.addAnimation("default", 0, false);
		anim.AddFrame(11);
		sign.SetOffset(SIGN_OFFSET);
		sign.SetRelativeZ(2);
		sign.RotateBy(rot, Vec2f());
		sign.ScaleBy(SCALE_FACTOR, SCALE_FACTOR);
		sign.SetVisible(false);
	}
}

const string[] shift_needed = {
	"mat_sulphur",
	"mat_iron",
	"mat_gold",
	"mat_copper",
	"mat_coal",
	"mat_mithril",
	"mat_mithrilenriched",
	"mat_meat",
	"mat_ironingot",
	"mat_goldingot",
	"mat_copperingot",
	"mat_mithrilingot",
	"mat_steelingot",
	"mat_concrete",
	"mat_wood",
	"mat_stone",
	"mat_dirt",
	"mat_matter",
};

void updateIconLayer(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	string icon_name = blob.get_string("compactor_icon_name");
	if (icon_name.empty()) return;
	icon_name = CFileMatcher(blob.get_string("compactor_icon_name")).getFirst();
	Vec2f icon_dims = blob.get_Vec2f("compactor_icon_dims");
	CSpriteLayer@ icon = this.getSpriteLayer("icon");
	CSpriteLayer@ sign = this.getSpriteLayer("sign");
	if (icon is null || icon.getFilename()!=icon_name) {
		this.RemoveSpriteLayer("icon");
		@icon = this.addSpriteLayer("icon", icon_name, icon_dims.x, icon_dims.y, blob.getTeamNum(), 0);
		icon.SetVisible(false);
	} else {
		if (blob.get_u32("compactor_quantity")<1) {
			icon.SetVisible(false);
			if (sign !is null)
				sign.SetVisible(false);
			return;
		}
		icon.SetVisible(true);
		if (sign !is null)
			sign.SetVisible(true);
		icon.ResetTransform();
		icon.SetOffset(SIGN_OFFSET);
		icon.SetRelativeZ(2.2f);
		if (!blob.get_string("compactor_resource").empty())
			icon.SetOffset(icon.getOffset()+(shift_needed.find(blob.get_string("compactor_resource"))>-1?Vec2f(0, -3):Vec2f_zero));
		icon.RotateBy(blob.get_f32("rot"), Vec2f());
		icon.SetFrameIndex(blob.get_u8("compactor_icon_frame"));
		icon.ScaleBy(SCALE_FACTOR, SCALE_FACTOR);
	}
}

void RemoveSignLayer(CSprite@ this)
{
	this.RemoveSpriteLayer("sign");
	this.RemoveSpriteLayer("icon");
}

void onTick(CBlob@ this)
{
	server_Sync(this);
	updateIconLayer(this.getSprite());
}

void client_UpdateName(CBlob@ this)
{
	if (isClient())
	{
		this.setInventoryName("Compactor\n(" + this.get_u32("compactor_quantity") + " " + this.get_string("compactor_resource_name") + ")");
	}
}

const string[] acceptable_blobs = {
	"egg",
	"mine",
	"fragmine",
	"keg",
	"guidedrocket",
	"claymore",
	"suicidevest",
	"sponge",
	"lantern",
	"log",
};

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	if (!blob.isAttached() && !blob.hasTag("dead") && (blob.hasTag("material") || blob.hasTag("hopperable") || acceptable_blobs.find(blob.getName())>-1))
	{
		string compactor_resource = this.get_string("compactor_resource");
		
		if ((compactor_resource == "" || this.get_u32("compactor_quantity")<1))
		{
			this.set_string("compactor_resource", blob.getName());
			this.set_string("compactor_resource_name", blob.getInventoryName());
			
			compactor_resource = blob.getName();
			this.set_string("compactor_icon_name", blob.inventoryIconName);
			this.set_Vec2f("compactor_icon_dims", blob.inventoryFrameDimension);
			this.set_u8("compactor_icon_frame", blob.inventoryIconFrame);

			if (blob.hasTag("material")) {
				Animation@ anim = blob.getSprite().getAnimation("default");
				if (anim !is null) {
					this.set_u8("compactor_icon_frame", anim.getFrame(anim.getFramesCount()-1));
				}
			}
		}
		
		if (blob.getName() == compactor_resource)
		{
			if (isServer()) 
			{
				this.add_u32("compactor_quantity", blob.getQuantity());
				
				blob.Tag("dead");
				blob.server_Die();
				server_Sync(this);
			}
			
			if (isClient())
			{
				this.getSprite().PlaySound("bridge_open.ogg");
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	string text = this.get_u32("compactor_quantity") > 0?("Take a stack of "+this.get_string("compactor_resource_name")):"Compactor's empty";
	CButton@ button_withdraw = caller.CreateGenericButton(20, Vec2f(0, 0), this, this.getCommandID("compactor_withdraw"), text, params);
	if (button_withdraw !is null)
	{
		button_withdraw.SetEnabled(this.get_u32("compactor_quantity") > 0);
	}
}

// KAG's CBlob.Sync() is nonfunctional shit
void server_Sync(CBlob@ this)
{
	if (isServer())
	{
		CBitStream stream;
		stream.write_string(this.get_string("compactor_resource_name"));
		stream.write_string(this.get_string("compactor_resource"));
		stream.write_u32(this.get_u32("compactor_quantity"));
		
		this.SendCommand(this.getCommandID("compactor_sync"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("compactor_withdraw"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && this.get_string("compactor_resource") != "")
		{
			u32 current_quantity = this.get_u32("compactor_quantity");
		
			if (isServer() && current_quantity > 0) 
			{
				CBlob@ blob = server_CreateBlob(this.get_string("compactor_resource"), this.getTeamNum(), this.getPosition());
				if (blob !is null)
				{
					u32 quantity = Maths::Min(current_quantity, blob.getMaxQuantity());
					u32 new_quantity = Maths::Max(current_quantity - quantity, 0);
										
					blob.server_SetQuantity(quantity);
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
						caller.server_PutInInventory(carried);
					caller.server_Pickup(blob);
					
					this.set_u32("compactor_quantity", new_quantity);
					if (new_quantity == 0)
					{
						this.set_string("compactor_resource", "");
						this.set_string("compactor_resource_name", "");
						
						server_Sync(this);
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID("compactor_sync"))
	{
		if (isClient())
		{
			string name = params.read_string();
			string config = params.read_string();
			u32 quantity = params.read_u32();
			
			this.set_string("compactor_resource_name", name);
			this.set_string("compactor_resource", config);
			this.set_u32("compactor_quantity", quantity);
			
			client_UpdateName(this);
		}
	}
}

void onDie(CBlob@ this)
{
	s32 current_quantity = this.get_u32("compactor_quantity");
	if (isServer() && current_quantity > 0) 
	{
		const string resource_name = this.get_string("compactor_resource");
		const u8 team = this.getTeamNum();
		const Vec2f pos = this.getPosition();
		int loop_amount = 0;
		while (current_quantity > 0 && loop_amount < max_loop)
		{
			loop_amount++;
			CBlob@ blob = server_CreateBlob(resource_name, team, pos);
			if (blob !is null)
			{
				u32 quantity = Maths::Min(current_quantity, blob.getMaxQuantity());
				current_quantity = Maths::Max(current_quantity - quantity, 0);
									
				blob.server_SetQuantity(quantity);
				blob.setVelocity(getRandomVelocity(0, XORRandom(400) * 0.01f, 360));
			}
		}
		
		server_Sync(this);
	}
}
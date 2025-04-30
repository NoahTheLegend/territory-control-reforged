#include "MakeMat.as";
#include "Requirements.as";

const u16 MAX_LOOP = 10; // what you get for breaking it
const u16 LOOP_RNG = 40; // variation on what will spawn if broken 
const Vec2f SIGN_OFFSET(0, -4);
const f32 SCALE_FACTOR = 1.0f;

void onInit(CSprite@ this)
{
	this.SetZ(-50);
	updateIconLayer(this);
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	
	this.set_u32("compactor_quantity", 0);
	this.set_string("compactor_resource", "");
	this.set_string("compactor_resource_name", "");
	
	this.addCommandID("compactor_withdraw");
	this.addCommandID("add_filter_item");
	this.addCommandID("compactor_sync");
	this.addCommandID("client_promp_sync");

	this.set_string("filtername", "anything");
	this.set_string("invname", "anything");
	
	this.Tag("remote_storage");
	AddSignLayerFrom(this.getSprite());

	client_PromptSync(this);
}

void client_PromptSync(CBlob@ this)
{
	if (isServer()) return;

	this.SendCommand(this.getCommandID("client_promp_sync"));
}

void onTick(CBlob@ this)
{
	client_UpdateName(this);
}

void client_UpdateName(CBlob@ this)
{
	if (isClient())
	{
		string name = this.get_string("invname");
		this.setInventoryName("Compactor\n(" + this.get_u32("compactor_quantity") + " " + this.get_string("compactor_resource_name") + ")\n"+"Filter: "+name);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this is null || blob is null) return;
	if (this.get_string("filtername") != "anything" && blob.getName() != this.get_string("filtername")) return;

	if (!blob.isAttached() && !blob.hasTag("dead") && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		string compactor_resource = this.get_string("compactor_resource");

		if (isServer() && compactor_resource == "")
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

			server_Sync(this);
		}
		
		if (blob.getName() == compactor_resource)
		{
			if (isServer()) 
			{
				this.add_u32("compactor_quantity", blob.getQuantity());

				blob.Tag("dead");
				blob.server_Die();

				this.set_string("compactor_icon_name", blob.inventoryIconName);
				this.set_Vec2f("compactor_icon_dims", blob.inventoryFrameDimension);
				this.set_u8("compactor_icon_frame", blob.inventoryIconFrame);

				server_Sync(this);
			}
			
			if (isClient())
			{
				this.getSprite().PlaySound("bridge_open.ogg");
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	if ((this.getTeamNum() < 7 && (caller.getTeamNum() == this.getTeamNum())) || this.getTeamNum() > 6) {
		CButton@ button_withdraw = caller.CreateGenericButton(20, Vec2f(0, 0), this, this.getCommandID("compactor_withdraw"), "Take a stack", params);
		if (button_withdraw !is null)
		{
			button_withdraw.SetEnabled(this.get_u32("compactor_quantity") > 0);
		}
		Vec2f buttonPos;

		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null)
		{
			u16 carried_netid = carried.getNetworkID();
			CBitStream params;
			params.write_u16(carried_netid);
			caller.CreateGenericButton("$" + carried.getName() + "$", Vec2f(0,-8), this, this.getCommandID("add_filter_item"), "Add to Filter", params);
		}
	}
}

// KAG's CBlob.Sync() is nonfunctional shit
// just get gud, sync works fine if you use it right - Rob
void server_Sync(CBlob@ this)
{
	if (isServer())
	{
		CBitStream stream;
		stream.write_string(this.get_string("compactor_resource_name"));
		stream.write_string(this.get_string("compactor_resource"));
		stream.write_u32(this.get_u32("compactor_quantity"));
		stream.write_string(this.get_string("filtername"));
		stream.write_string(this.get_string("invname"));
		stream.write_string(this.get_string("compactor_icon_name"));
		stream.write_Vec2f(this.get_Vec2f("compactor_icon_dims"));
		stream.write_u8(this.get_u8("compactor_icon_frame"));

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
					caller.server_Pickup(blob);
					
					this.set_u32("compactor_quantity", new_quantity);
					if (new_quantity == 0)
					{
						this.set_string("compactor_resource", "");
						this.set_string("compactor_resource_name", "");
					}
					
					server_Sync(this);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("add_filter_item"))
	{
		CBlob@ carried = getBlobByNetworkID(params.read_u16());

		//if(isServer())
		if (carried !is null){
			if (carried.getName() == this.get_string("filtername"))
			{
				this.set_string("filtername", "anything");
				this.set_string("invname", "anything");
				return;
			}
			this.set_string("filtername", carried.getName());
			this.set_string("invname", carried.getInventoryName());
		}
	}
	else if (cmd == this.getCommandID("compactor_sync"))
	{
		if (isClient())
		{
			string name = params.read_string();
			string config = params.read_string();
			u32 quantity = params.read_u32();
			string filtername = params.read_string();
			string invname = params.read_string();
			string icon_name = params.read_string();
			Vec2f icon_dims = params.read_Vec2f();
			u8 icon_frame = params.read_u8();
			
			this.set_string("compactor_resource_name", name);
			this.set_string("compactor_resource", config);
			this.set_u32("compactor_quantity", quantity);
			this.set_string("filtername", filtername);
			this.set_string("invname", invname);
			this.set_string("compactor_icon_name", icon_name);
			this.set_Vec2f("compactor_icon_dims", icon_dims);
			this.set_u8("compactor_icon_frame", icon_frame);

			client_UpdateName(this);
			updateIconLayer(this.getSprite());
		}
	}
	else if (cmd == this.getCommandID("client_promp_sync"))
	{
		server_Sync(this);
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
		const int rng_amount = MAX_LOOP + XORRandom(LOOP_RNG);

		for (int a = 0; a < current_quantity && a < rng_amount; a++)
		{
			CBlob@ blob = server_CreateBlob(resource_name, team, pos);
			if (blob is null) { continue; }

			u32 quantity = Maths::Min(current_quantity, blob.getMaxQuantity());
			current_quantity = Maths::Max(current_quantity - quantity, 0);
									
			blob.server_SetQuantity(quantity);
			blob.setVelocity(getRandomVelocity(0, XORRandom(400) * 0.01f, 360));
		}

		server_Sync(this);
	}
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
	if (!isClient()) return;

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
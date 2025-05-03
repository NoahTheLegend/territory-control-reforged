//#define SERVER_ONLY

#include "GunCommon"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.addCommandID("give picking up tag");
}

bool EngiPickup(CBlob@ this, CBlob@ item)
{
	if (this is null || item is null) return false;
	
	if (!this.hasScript("BlockPlacement.as")) return false;
	
	return (/*item.hasScript("MaterialStandard.as") || */item.hasTag("builder pickup")) && !item.hasTag("ammo");
}

bool SoldiPickup(CBlob@ this)
{
	if (this.getName()!="soldat") return false;
	return false;
}

void Take(CBlob@ this, CBlob@ blob)
{
	if (!isServer()) return;

	CRules@ rules = getRules();
	CPlayer@ player = this.getPlayer();

	const string blobName = blob.getName();
	if (this is null || rules is null || blob is null) return;
	
	CBlob@ carried = this.getCarriedBlob();
	bool canPutInInventory = true;
	
	if (!this.isAttached() && !blob.hasTag("no pickup"))
	{		
		if ((this.getDamageOwnerPlayer() is blob.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			bool add = false;
			if (!blob.hasTag("no auto pickup") && (blob.hasTag("ammo") || blob.hasTag("material") || EngiPickup(this, blob))) //only add ammo if we have something that can use it, or if same ammo exists in inventory.
			{
				add = false;
				//array
				CBlob@[] items;
				if (this.getCarriedBlob() != null)
				{
					items.push_back(this.getCarriedBlob());
				}
				CInventory@ inv = this.getInventory();
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ item = inv.getItem(i);
					items.push_back(item);
				}
				for (int i = 0; i < items.size(); i++)
				{
					CBlob@ item = items[i];

					GunSettings@ settings;
					item.get("gun_settings", @settings);

					if (settings !is null && settings.AMMO_BLOB == blob.getName() || item.getName() == blob.getName())
					{
						add = true;
						break;
					}
				}
				if (EngiPickup(this, blob))
					add = true;
			}
			
			if (!add) return;
			
			//all this fuckery allows to check if the blob would take space we need for a carried blob
			Vec2f blob_old_pos = blob.getPosition();
			
			s32 blob_id = -1;
			if (carried !is null && this.isMyPlayer())
				blob_id = carried.getNetworkID();

			if (carried !is null)
			{
				return;
			}

			//tagging so gun doesn't stop reloading
			SendTagCommand(this, blob_id);
			
			//if inventory is full to the brim
			if (!this.server_PutInInventory(blob)) {
				SendTagCommand(this, blob_id);
				return;
			}
			
			//if we managed to put a blob in our inventory but then we can't store our carried - pulling that blob back
			if (carried !is null) {
				if (!this.server_PutInInventory(carried)) {
					this.server_PutOutInventory(blob);
					blob.setPosition(blob_old_pos);
				} else {
					this.server_Pickup(carried);
				}
			}
			//not keeping this tag
			SendTagCommand(this, blob_id);
		}
	}
}

bool SendTagCommand(CBlob@ this, s32 blob_id)
{
	if (blob_id < 0) return false;
	CBitStream params;
	params.write_u16(blob_id);
	this.SendCommand(this.getCommandID("give picking up tag"), params);
	
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}
	
	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				if (blob.getShape().vellen > 0.3f)
				{
					continue;
				}

				Take(this, blob);
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("give picking up tag"))
	{
		u16 blob_id; if (!params.saferead_u16(blob_id)) return;
		//if (isServer()) return;
		CBlob@ blob = getBlobByNetworkID(blob_id);
		
		if (blob is null) return;
		
		if (blob.hasTag("quick_detach"))
			blob.Untag("quick_detach");
		else
			blob.Tag("quick_detach");
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead"))
	{
		return;
	}

	const string blobName = blob.getName();
	bool addCooldown = false;

	if (addCooldown)
	{
		blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
		blob.SetDamageOwnerPlayer(blob.getPlayer());
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}

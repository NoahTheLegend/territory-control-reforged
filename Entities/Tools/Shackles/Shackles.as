#include "Hitters.as";
#include "Knocked.as";
#include "Survival_Structs.as";
#include "DeityCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}

	this.Tag("automat_activable");
}

string[] getRestrictedPlayers()
{
	string[] players = {

	};
	return players;
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		bool restrict = false;
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null){return;}
		u8 team = holder.getTeamNum();

		if (holder.getPlayer() !is null)
		{
			string[] players = getRestrictedPlayers();
			for (u16 i = 0; i < players.length; i++)
			{
				if (players[i] == holder.getPlayer().getUsername())
					restrict = true;
			}
		}
		
		TeamData@ team_data;
		GetTeamData(team, @team_data);

		bool slavery_enabled = true;
		
		if (team_data != null)
		{
			slavery_enabled = team_data.slavery_enabled;
			// print("" + slavery_enabled);
		}
		
		if (point.isKeyJustPressed(key_action1) || this.hasTag("pressing"))
		{
			this.Untag("pressing");

			if (slavery_enabled && getGameTime() >= this.get_u32("next attack") && getKnocked(holder) <= 0)
			{
				HitInfo@[] hitInfos;
				if (getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						CBlob@ blob = hitInfos[i].blob;

						bool do_continue = false;
						if (blob !is null && (blob.getName() == "peasant" || blob.getName() == "slave"))
						{
							CBlob@[] overlapping;
							blob.getOverlapping(@overlapping);
							for (u16 i = 0; i < overlapping.length; i++)
							{
								if (do_continue) continue;
								if (overlapping[i] !is null && overlapping[i].getName() == "ruins")
								{
									do_continue = true;
								}
							}
						}
						if (do_continue) continue;
						if (blob !is null && blob.hasTag("player") && blob.getTeamNum() != team && blob.get_u8("deity_id") != Deity::ivan && blob.get_u8("deity_id") != Deity::swaglag)
						{
							f32 chance = 1.0f - (blob.getHealth() / blob.getInitialHealth());
							if (blob.getName() == "slave") chance = 1.0f;
							if (blob.get_f32("babbyed") > 0) chance = 1.00f;
							
							// print("" + chance);
						
							if ((chance > 0.50f && XORRandom(100) < chance * 80) || (getKnocked(blob) > 15 && chance > 0.2f))
							{
								// if (isClient())
								// {
									// this.getSprite().PlaySound("shackles_success.ogg", 1.25f, 1.00f);
								// }
								
								if (isServer())
								{
									CBlob@ slave = server_CreateBlob("slave", holder.getTeamNum(), blob.getPosition());
									slave.set_u8("slaver_team", holder.getTeamNum());
									
									if (slave !is null)
									{
										if (!restrict)
										{
											if (blob.getPlayer() !is null) slave.server_SetPlayer(blob.getPlayer());
											slave.set_string("sleeper_name", blob.get_string("sleeper_name"));
											slave.set_bool("sleeper_sleeping", blob.get_bool("sleeper_sleeping"));
											slave.Sync("sleeper_name", true);
											slave.Sync("sleeper_sleeping", true);
											blob.server_Die();
											this.server_Die();
										}
										else
										{
											this.getSprite().PlaySound("klaxon" + XORRandom(4) + ".ogg", 0.8f, 1.0f);
											this.getSprite().PlaySound("klaxon" + XORRandom(4) + ".ogg", 0.8f, 1.0f);
											if (holder.getPlayer() !is null) slave.server_SetPlayer(holder.getPlayer());
											slave.set_string("sleeper_name", holder.get_string("sleeper_name"));
											slave.set_bool("sleeper_sleeping", holder.get_bool("sleeper_sleeping"));
											slave.Sync("sleeper_name", true);
											slave.Sync("sleeper_sleeping", true);
											holder.server_Die();
											this.server_Die();
										}
									}
								}
								
								return;
							}
							else
							{
								this.set_u32("next attack", getGameTime() + 90);
							
								if (isClient())
								{
									this.getSprite().PlaySound("shackles_fail.ogg", 0.80f, 1.00f);
								}
								
								return;
							}
						}
					}
				}
			}
			else
			{
				if (holder.isMyPlayer()) Sound::Play("/NoAmmo");
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob !is null && blob.hasTag("flesh")) return false;
	return true;
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	// detached.Untag("noShielding");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
	// attached.Tag("noShielding");
}
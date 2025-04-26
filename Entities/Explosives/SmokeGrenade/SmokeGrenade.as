void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;

	this.getSprite().PlaySound("grenade_pinpull.ogg");

	this.getSprite().SetEmitSoundPaused(false);
	this.SetLight(true);
	this.SetLightRadius(48.0f);

	this.Tag("projectile");
}

void onTick(CBlob@ this)
{
	if(this.hasTag("dead")) return;

	if(this.getTickSinceCreated() >= 90)
	{
		this.Tag("dead");
		this.server_Die();
		if (!isClient() && !this.isOnScreen()) return;
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f)
	{
		Sound::Play("/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f), 1.2f);
	}
}

void onDie(CBlob@ this)
{
	if (isClient())
	{
		this.getSprite().PlaySound("FlashGrenade_Boom.ogg");
	}

	for (int i = 0; i < 8; i++)
	{
		CBlob@ blob = server_CreateBlob("smokegasgrenade", this.getTeamNum(), this.getPosition());

		if (blob !is null)
		{
			blob.server_SetQuantity(7 + XORRandom(1));
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

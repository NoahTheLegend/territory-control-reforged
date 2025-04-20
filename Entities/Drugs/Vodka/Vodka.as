void onInit(CBlob@ this)
{
	this.addCommandID("server_consume");
	this.addCommandID("client_consume");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("server_consume"), "Drink");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server_consume") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		caller.server_Heal(1.5f);

		SetDrunk(caller);

		CBitStream stream;
		stream.write_netid(caller.getNetworkID());
		this.SendCommand(this.getCommandID("client_consume"), stream);

		this.server_Die();
	}
	else if (cmd == this.getCommandID("client_consume") && isClient())
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller is null) return;

		CSprite@ sprite = caller.getSprite();
		sprite.PlaySound("gasp.ogg");
		sprite.PlaySound("Gurgle2.ogg");

		SetDrunk(caller);
	}
}

void SetDrunk(CBlob@ caller)
{
	if (!caller.hasScript("Drunk_Effect.as"))
	{
		caller.AddScript("Drunk_Effect.as");
	}
	
	caller.set_u16("drunk", Maths::Min(caller.get_u16("drunk") + 5, 60000));
	caller.set_u32("next sober", getGameTime());
}

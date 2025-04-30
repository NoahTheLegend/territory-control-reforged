void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);

	this.Tag("boots");

	if (this.getName() == "combatboots" || this.getName() == "carbonboots")
		this.Tag("armor");

	this.getCurrentScript().tickFrequency = 300;
}
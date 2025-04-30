void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "bucket")
    	this.set_string("reload_script", "");
}
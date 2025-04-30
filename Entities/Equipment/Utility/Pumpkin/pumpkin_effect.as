void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "pumpkin")
        this.set_string("reload_script", "");
}
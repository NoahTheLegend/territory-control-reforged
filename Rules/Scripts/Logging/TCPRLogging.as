void onTick(CRules@ this)
{
    if (getGameTime() % 30 == 0 && isClient())
    {
        ConfigFile cfg;
        if (cfg.loadFile("../Cache/vars.cfg"))
        {
            u8 timer = cfg.read_u8("timer", 0);
            if (timer == 1)
            {
                CBitStream params;
                this.SendCommand(this.getCommandID("start_timer"), params);
                
                this.chat = false;
                getNet().DisconnectClient();
            }
        }
        else
        {
            ConfigFile cfg;
            cfg.add_u8("timer", 0);
            cfg.saveFile("vars.cfg");
        }
    }
}
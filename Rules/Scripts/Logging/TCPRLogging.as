const string[] teams = {
    "Blue",
    "Red",
    "Green",
    "Purple",
    "Orange",
    "Cyan",
    "Violet",
    "Neutral"
};

void onTick(CRules@ this)
{
    if (getGameTime() % 300 == 0)
    {
        if (isClient())
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

        if (isServer())
        {
            // abstraction:
            // data[0] = clantag + data[1] = charactername + | data[2] = username + data[3] = team name+ | data[4] = coins

            string data = "<playerlist>";
            for (u8 i = 0; i < getPlayersCount(); i++)
            {
                CPlayer@ player = getPlayer(i);
                if (player !is null)
                {
                    string clantag = player.getClantag();
                    string characterName = player.getCharacterName();
                    string username = player.getUsername();
                    int tn = player.getTeamNum();
                    string teamName = tn >= 0 && tn <= 6 ? teams[tn] : teams[teams.length - 1];
                    u16 coins = player.getCoins();

                    data += clantag + " | " + characterName + " | " + username + " | " + teamName + " | " + coins + ";\n";
                }
            }

            tcpr(data);
        }
    }
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    if (isServer())
    {
        tcpr(player.getUsername()+" has joined the server!");
        tcpr("<vpncheck> "+player.server_getIP()+" "+player.getUsername());
    }
}

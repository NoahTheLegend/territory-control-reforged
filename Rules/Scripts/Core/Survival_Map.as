#include "CustomBlocks.as";
#include "MapType.as";

const string[] OffiMaps = {
	"TFlippy_TC_Mesa",
	"TFlippy_TC_Tenshi_Lakes",
	"TFlippy_TC_Bobox",
	"TFlippy_THD_TC_Kagtorio",
	"TFlippy_TC_Derpo",
	"TFlippy_TC_Fug",
	"TFlippy_TC_Valley",
	"TFlippy_Rob_TC_Socks",
	"Xeno_TC_LostAtlantis",
    "Xeno_Plains&Hills",
	"Xeno_TC_Graveyard",
	"Tenshi_TC_DeadEchoSeven_v1",
	"Imbalol_TC_OilRig",
	"Imbalol_TC_LongForgotten",
	"TFlippy_THD_TC_Foghorn",
	"Ginger_TC_Mookcity",
	"Ginger_TC_Bridge",
	"Ginger_TC_Ridgelands_V2",
	"Ginger_TC_Royale_V3",
	"Ginger_Tenshi_TC_Generations_V1",
	"Ginger_TC_Drudgen",
	"Ginger_TC_Bombardment_V2",
	"Ginger_TC_Dehydration",
	"Ginger_TC_Murderholes_V2",
	"Ginger_TC_Aether",
	"Ginger_TC_Royale",
	"Ginger_TC_Highlands_V4",
	"Ginger_TC_Samurai.png",
	"Ginger_TC_Cove_v2",
	"Ginger_TC_Equinox",
	"Goldy_TC_Propesko",
	"Goldy_TC_Sewers_v2",
	"Goldy_TC_Netherland_v2",
	"Goldy_TC_ThomasMega",
	"Skemonde_TC_Gooby_v3fM",
	"Skemonde_TC_Morgenland_v4",
	"Goldy_TC_Hollows",
	"Ginger_TC_Lagoon",
	"Ginger_TC_Pirates",
	"Imbalol_TC_ChickenKingdom_v2",
	"Ginger_TC_Seaside",
	"TFlippy_TC_Nostalgia",
	"Imbalol_TC_UPFCargo",
	"Ginger_Tenshi_TC_Extinction",
	"Goldy_TC_Basement_v2",
	"JmD_TC_Poultry_v6",
	"Sylw_LawrenceSlum",
	"Tenshi_TC_WellOiledMachine_v2",
	"TFlippy_TC_Skynet",
	"TFlippy_TC_Reign",
	"TFlippy_TC_Thomas",
	"Vamistorio_TC_IkoPit_v2"
};

const string[] MemeMaps = {
	//"Goldy_TC_DoubleVision", //too laggy to use
	//"Imbalol_TC_City_v1",
	//"Naime_TC_Land",
	"Small",
	"Large",
	"Maybe_Cool_Tc_Map",
	"Ginger_TC_Bebop",
	"Ginger_TC_Highlands",
	"Goldy_TC_Hollows",
	"Xeno_TC_AncientTemple",
	"Vamfistorio_Noah",
	"TFlippy_TC_Dung"
};

const string[] OldMaps = {
	"TFlippy_Barrens_v6",
	"TFlippy_SkyTown_v1",
	"TFlippy_UncleBen_v5",
	"TFlippy_Paxton_v3",
	"TFlippy_Coalands_v1",
	"TFlippy_Kingdom_v7",
	"TFlippy_Pile_v3",
	"TFlippy_Spilands_v3",
	"TFlippy_TC_MasterRace",
	"TFlippy_TTH_City_v8",
	"TFlippy_UncleBen_v5",	
	"WorldsCollide"
};

void onInit(CRules@ this)
{
	Reset(this, getMap());

	this.set("maptypes-offi", OffiMaps);
	this.set("maptypes-meme", MemeMaps);
	this.set("maptypes-old", OldMaps);

}

void onRestart(CRules@ this)
{
	Reset(this, getMap());
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	Reset(rules, this);
}

void Reset(CRules@ this, CMap@ map)
{
	if (map !is null)
	{
		if (!this.exists("map_type")) this.set_u8("map_type", MapType::normal);
	}
}

#include "GunCommon.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.isAttached()) return 0;
	return damage;
}

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	//settings.CLIP = 0; //Amount of ammunition in the gun at creation
	settings.TOTAL = 1; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 25; //Time in between shots
	settings.RELOAD_TIME = 25; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_smallrocket"; //Ammunition the gun takes

	//Bullet
	settings.B_PER_SHOT = 1; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 0; //the higher the value, the more 'uncontrollable' bullets get
	//settings.B_GRAV = Vec2f(0, 0.001); //Bullet gravity drop
	settings.B_SPEED = 0; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	//settings.B_TTL = 100; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	//settings.B_DAMAGE = 4.0f; //1 is 1 heart
	//settings.B_TYPE = HittersTC::bullet_high_cal; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -10; //0 is default, adds recoil aiming up
	//settings.G_RANDOMX = true; //Should we randomly move x
	//settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 7; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 6; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "BazookaFire.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "BazookaReload.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-16, 0); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.set_string("CustomCycle", "BazookaCycle");
	this.set_string("CustomCase", "");
	this.set_u32("CustomGunRecoil", 2);
	this.set_f32("CustomReloadPitch", 0.65f);
	this.Tag("CustomMuzzleLeft");
	this.set_string("ProjBlob", "smallrocket");
	this.set_Vec2f("ProjOffset", Vec2f(-15, -2));
}
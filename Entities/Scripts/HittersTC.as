
namespace HittersTC
{
	shared enum hits_tc
	{
		bullet_low_cal = 100,
		bullet_high_cal,
		shotgun,
		railgun_lance,
		plasma,
		forcefield,
		electric,
		radiation,
		nanobot,
		magix,
		staff,
		hammer,
		foof,
		poison,
		disease
	};
}

bool isGunHitter (u32 hitterData)
{
	return hitterData >= HittersTC::bullet_low_cal && hitterData < HittersTC::railgun_lance;
}

bool isAlienGunHitter (u32 hitterData)
{
	return hitterData >= HittersTC::railgun_lance && hitterData <= HittersTC::plasma;
}
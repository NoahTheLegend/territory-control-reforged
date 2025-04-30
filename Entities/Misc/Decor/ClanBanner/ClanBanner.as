#include "BannerCommon.as"

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
    CSpriteLayer@ l = this.getSprite().addSpriteLayer("l", "ClanBannerDecal.png", 16, 32);
    
    this.addCommandID("load_image");
    this.addCommandID("sync");
    this.addCommandID("init_sync");

    if (!isClient()) return;
    int cb_id = Render::addBlobScript(Render::layer_objects, this, "ClanBanner.as", "renderCanvas");

    this.getSprite().SetZ(-10.0f);
    this.getSprite().SetRelativeZ(-10.0f);

    if (l !is null)
    {
        l.SetRelativeZ(-9.5f);
        l.SetVisible(false);
    }

    this.set_string("last_user", "");
    this.getCurrentScript().tickFrequency = 90;
}

void renderCanvas(CBlob@ this, int id)
{
    if (!this.hasTag("created_texture")) return;
    Vec2f canvas_size = this.get_Vec2f("canvas_size");
    
    float angle = this.getAngleDegrees();
    Vec2f pos = this.getPosition() - Vec2f(canvas_size.x/2, canvas_size.y/2).RotateBy(angle);

    Vec2f[] v_pos;
    Vec2f[] v_uv;

    v_uv.push_back(Vec2f(0, 0)); v_pos.push_back(pos + Vec2f(0, 0).RotateBy(angle)); //tl
    v_uv.push_back(Vec2f(1, 0)); v_pos.push_back(pos + Vec2f(canvas_size.x, 0).RotateBy(angle)); //tr
    v_uv.push_back(Vec2f(1, 1)); v_pos.push_back(pos + Vec2f(canvas_size.x, canvas_size.y).RotateBy(angle)); //br
    v_uv.push_back(Vec2f(0, 1)); v_pos.push_back(pos + Vec2f(0, canvas_size.y).RotateBy(angle)); //bl

    Render::Quads("banner" + this.getNetworkID(), -5.0f, v_pos, v_uv);

    v_pos.clear();
    v_uv.clear();
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("sync"))
    {
        if (!isClient()) return;

        Vec2f canvas_size;
        if (!params.saferead_Vec2f(canvas_size)) return;

        if (canvas_size.x > max_canvas_size.x
            || canvas_size.y > max_canvas_size.y)
                return;

        this.set_Vec2f("canvas_size", canvas_size);
        int max_size = canvas_size.x * canvas_size.y;

        string last_user = "";
        if (!params.saferead_string(last_user)) return;

        this.set_string("last_user", last_user);
        this.setInventoryName("Last artist: "+last_user);

        string tex_name = "banner"+this.getNetworkID();
        if (Texture::exists(tex_name))
        {
            Texture::destroy(tex_name);
        }
        
        if (!Texture::createBySize(tex_name, canvas_size.x, canvas_size.y))
		{
			warn("Texture creation failed");
            return;
		}
        
        ImageData@ data = Texture::data(tex_name);
        if (data is null)
        {
            warn("Image data is null!");
            return;
        }

        int skips = 0;
        for (int i = 0; i < max_size; i++)
        {
            int step;
            if (!params.saferead_s32(step))
            {
                skips++;
                continue;
            }

            data.put(i%canvas_size.x, Maths::Floor(i/canvas_size.x), SColor(step));
        }
        
       // printf("Created texture '"+tex_name+"', size "+data.width()+" x "+data.height()+" with "+skips+" skips");

        if(!Texture::update(tex_name, data))
		{
			warn("Texture update failed!");
		}

        this.Tag("created_texture");
    }
    else if (cmd == this.getCommandID("init_sync"))
    {
        if (!isServer()) return;

        Sync(this);
    }
    else if (cmd == this.getCommandID("load_image"))
    {
        if (!isServer()) return;
        int[] canvas;

        Vec2f canvas_size = params.read_Vec2f();
        this.set_Vec2f("canvas_size", canvas_size);

        string username = params.read_string();
        this.set_string("last_user", username);

        int max_size = canvas_size.x * canvas_size.y;
        for (int i = 0; i < max_size; i++)
        {
            int step;
            if (!params.saferead_s32(step))
            {
                canvas.push_back(0x00000000);
                continue;
            }
            canvas.push_back(step);
        }
        this.set("canvas", @canvas);

        Sync(this);
    }
}

void Sync(CBlob@ this)
{
    Vec2f canvas_size = this.get_Vec2f("canvas_size");
    int max_size = canvas_size.x * canvas_size.y;

    int[]@ canvas;
    if (!this.get("canvas", @canvas) || canvas.size() != max_size)
    {
        //warn("Failed to load banner canvas array on sync");
        return;
    }

    CBitStream params;
    params.write_Vec2f(canvas_size);
    params.write_string(this.get_string("last_user"));
    for (int i = 0; i < max_size; i++)
    {
        params.write_s32(canvas[i]);
    }
    
    this.SendCommand(this.getCommandID("sync"), params);
}

void onTick(CBlob@ this)
{
    if (isClient())
    {
        string tex_name = "banner"+this.getNetworkID();
        if (!Texture::exists(tex_name))
        {
            CBitStream params;
            this.SendCommand(this.getCommandID("init_sync"), params);
        }
    }
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}
// use this script only in pair with LoaderUtilities.as
bool rope_map_updated = false;
u8[][] MAP_TILES;

enum MapTileType
{
    MAP_TILE_NONE = 0,
    MAP_TILE_SOLID = 1,
    MAP_TILE_SOLID_BLOB_0 = 2,
    MAP_TILE_SOLID_BLOB_1 = 3,
    MAP_TILE_SOLID_BLOB_2 = 4,
    MAP_TILE_SOLID_BLOB_3 = 5,
    MAP_TILE_SOLID_BLOB_4 = 6,
    MAP_TILE_SOLID_BLOB_5 = 7,
    MAP_TILE_SOLID_BLOB_6 = 8,
    MAP_TILE_SOLID_BLOB_N = 9,
};

void ResetRopeMap(CMap@ map)
{
    if (map is null) return;

    int width = map.tilemapwidth;
    int height = map.tilemapheight;

    u8[][] new_MAP_TILES(width, u8[](height, MapTileType::MAP_TILE_NONE));
    MAP_TILES = new_MAP_TILES;

    SaveMap(map);
}

void UpdateMap(CMap@ map, int offset, u16 tileType)
{
    if (MAP_TILES.size() == 0 || MAP_TILES[0].size() == 0)
    {
        ResetRopeMap(map);
    }
    
    int width = map.tilemapwidth;
    int height = map.tilemapheight;

    int x = offset % width;
    int y = offset / width;

    if (x < 0 || x >= width || y < 0 || y >= height)
    {
        return;
    }
    
    u8 type = map.isTileSolid(tileType) ? MapTileType::MAP_TILE_SOLID : MapTileType::MAP_TILE_NONE;
    MAP_TILES[x][y] = type;

    rope_map_updated = true;

}

void SaveMap(CMap@ map)
{
    map.set("rope_map", MAP_TILES);
}
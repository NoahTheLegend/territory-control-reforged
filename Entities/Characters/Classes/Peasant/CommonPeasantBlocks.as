// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as";
#include "Requirements.as";
#include "Descriptions.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	// AddIconToken("$icon_faction$", "Tent.png", Vec2f(50, 48), 0);
	AddIconToken("$icon_faction$", "PeasantIcons.png", Vec2f(80, 32), 0);
	AddIconToken("$wood_triangle$", "WoodTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$stone_triangle$", "StoneTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$woodchest$", "WoodChest.png", Vec2f(16, 16), 0);
	AddIconToken("$neutral_door$", "1x1NeutralDoor.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_banditshack$", "BanditShack.png", Vec2f(40, 32), 0);
	AddIconToken("$icon_tavern$", "Tavern.png", Vec2f(56, 32), 0);
	AddIconToken("$bricks_block$", "World.png", Vec2f(8, 8), CMap::tile_bricks);
	AddIconToken("$bricks_back_block$", "World.png", Vec2f(8, 8), CMap::tile_bricks_back);

	BuildBlock[] page_0;
	blocks.push_back(page_0);

	{
		BuildBlock b(0, "camp", "$icon_faction$", "Found a Faction!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "coin", "", "Coins", 50);
		b.buildOnGround = true;
		b.size.Set(80, 24);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "neutral_door", "$neutral_door$", "Neutral Wooden Door\nPlace next to walls. Can be opened by anyone.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "banditshack", "$icon_banditshack$", "An Awful Rundown Bandit Shack\nGives you an option to become bandit scum.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wood_triangle", "$wood_triangle$", "Wooden Triangle");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_triangle", "$stone_triangle$", "Stone Triangle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "tavern", "$icon_tavern$", "Tavern\nA poorly built cozy tavern.\nOther neutrals may set their team here, paying you 20 coins for each spawn.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		b.buildOnGround = true;
		b.size.Set(56, 32);
		blocks[0].push_back(b);
	}
	{	//Report fil, he stole my fireplace // Ye ~Fil
		BuildBlock b(0, "fireplace", "$fireplace$", "Campfire\nCan be used to cook various foods.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bricks, "bricks", "$bricks_block$", "Fancy and cheap bricks.\n");
		AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 3);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bricks_back, "bricks_back", "$bricks_back_block$", "Fancy and cheap bricks wall.\n");
		AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "woodchest", "$woodchest$", "Wooden Chest:\n\nA regular wooden chest used for storage.\nCan be accessed by anyone.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "lantern", "$lantern$", descriptions[9]);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		//b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}

	BuildBlock[] page_1;
	blocks.push_back(page_1);

	BuildBlock[] page_2;
	blocks.push_back(page_2);
}

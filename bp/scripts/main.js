import { system, ItemTypes, ItemStack, BlockTypes, BlockPermutation } from "@minecraft/server";

const EXCLUDED_ITEM_TAGS = new Set([]);

system.run(() => {
  // item tags
  const itemTagMap = {};
  for (const { id } of ItemTypes.getAll()) {
    if (id === "minecraft:air") continue;
    for (const tag of new ItemStack(id).getTags()) {
      if (EXCLUDED_ITEM_TAGS.has(tag)) continue;
      (itemTagMap[tag] ??= []).push(id);
    }
  }

  // block tags
  const blockTagMap = {};
  for (const { id } of BlockTypes.getAll()) {
    if (id === "minecraft:air") continue;
    const perm = BlockPermutation.resolve(id);
    if (!perm) continue;
    for (const tag of perm.getTags()) {
      (blockTagMap[tag] ??= []).push({ id, states: perm.getAllStates() });
    }
  }

  const sortItems = (map) =>
    Object.fromEntries(
      Object.keys(map)
        .sort()
        .map((tag) => [tag, map[tag].sort()]),
    );

  const sortBlocks = (map) =>
    Object.fromEntries(
      Object.keys(map)
        .sort()
        .map((tag) => [tag, map[tag].sort((a, b) => a.id.localeCompare(b.id))]),
    );

  console.warn(
    "BEDROCK_TAG_DATA:" +
      JSON.stringify({ items: sortItems(itemTagMap), blocks: sortBlocks(blockTagMap) }),
  );
});

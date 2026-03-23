import { system, ItemTypes, ItemStack, BlockTypes, BlockPermutation } from "@minecraft/server";

system.run(() => {
  // item tags
  const itemTagMap = {};
  for (const { id } of ItemTypes.getAll()) {
    for (const tag of new ItemStack(id).getTags()) {
      (itemTagMap[tag] ??= []).push(id);
    }
  }

  // block tags
  const blockTagMap = {};
  for (const { id } of BlockTypes.getAll()) {
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

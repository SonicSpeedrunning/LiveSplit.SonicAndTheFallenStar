// Sonic and the Fallen Star
// Autosplitter
// Coding: BenInSweden, Jujstme
// Last update: Nov 3rd, 2022

state("Sonic and the Fallen Star") {}

startup
{
    int[] FrameIDs = { 17, 19, 23, 25, 29, 31, 35, 37, 41, 43, 47, 49, 53, 55, 59, 61, 65, 67, 69 };
    vars.Acts = new Dictionary<int, byte>();
    byte z = 0;
    foreach (var entry in FrameIDs)
    {
        vars.Acts.Add(entry, z);
        if (entry != FrameIDs[FrameIDs.Length - 1]) vars.Acts.Add(entry + 1, z);
        z++;
    }

    string[] zoneName = { "Shappire Sights", "Tropical Tracks", "Discount Districts", "Bubble Blossom", "Frozen Mountain", "Gusty Greenhouse", "Carnival Crater", "Raspberry River", "Thunder Turbine" };
    for (int i = 0; i < zoneName.Length; i++)
    {
        for (int j = 0; j < 2; j++)
        {
            settings.Add((i * 2 + j).ToString(), true, zoneName[i] + " - Act " + (j + 1).ToString());
        }
    }
}

init
{
    var length = new System.IO.FileInfo(modules.First().FileName.Substring(0, modules.First().FileName.Length - 3) + "dat").Length;
    switch(length)
    {
        case 0x110DBF9A: vars.FrameOffset = 2; version = "v1.1.1 Edit 4"; break;
        default: vars.FrameOffset = 0; version = "Default"; break;
    }

    var scanner = new SignatureScanner(game, modules.First().BaseAddress, modules.First().ModuleMemorySize);
    var ptr = scanner.Scan(new SigScanTarget(2, "8B 3D ???????? 8B F7"));
    if (ptr == IntPtr.Zero) throw new NullReferenceException("Sigscanning failed!");
    vars.FrameID = new MemoryWatcher<int>(new DeepPointer(game.ReadPointer(ptr), game.ReadValue<int>(ptr + 0xC)));

    // Default values
    current.Act = 0;
    current.FrameID = 0;
}

update
{
    vars.FrameID.Update(game);
    current.FrameID = vars.FrameID.Current - vars.FrameOffset;
    if (vars.Acts.ContainsKey(current.FrameID)) current.Act = vars.Acts[current.FrameID];
}

start
{
    return old.FrameID == 9 && current.FrameID == 15;
}

reset
{
    return old.FrameID != current.FrameID && (current.FrameID == 5 || current.FrameID == 6);
}

split
{
    if (current.Act == old.Act + 1) return settings[old.Act.ToString()];
}

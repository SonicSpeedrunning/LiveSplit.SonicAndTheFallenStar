// Sonic and the Fallen Star
// Autosplitter
// Coding: BenInSweden, Jujstme
// Last update: Nov 3rd, 2022

state("Sonic and the Fallen Star") {}

startup
{
    vars.Acts = new Dictionary<int, byte>{
        { 17, 0 }, { 18, 0 }, // Shappire Sights Act 1
        { 19, 1 }, { 20, 1 }, // Shappire Sights Act 2
        { 23, 2 }, { 24, 2 }, // Tropical Tracks Act 1
        { 25, 3 }, { 26, 3 }, // Tropical Tracks Act 2
        { 29, 4 }, { 30, 4 }, // Discount Districts Act 1
        { 31, 5 }, { 32, 5 }, // Discount Districts Act 2
        { 35, 6 }, { 36, 6 }, // Bubble Blossom Act 1
        { 37, 7 }, { 38, 7 }, // Bubble Blossom Act 2
        { 41, 8 }, { 42, 8 }, // Frozen Fountain Act 1
        { 43, 9 }, { 44, 9 }, // Frozen Fountain Act 2
        { 47, 10 }, { 48, 10 }, // Gusty Greenhouse Act 1
        { 49, 11 }, { 50, 11 }, // Gusty Greenhouse Act 2
        { 53, 12 }, { 54, 12 }, // Carnival Crater Act 1
        { 55, 13 }, { 56, 13 }, // Carnival Crater Act 2
        { 59, 14 }, { 60, 14 }, // Raspberry River Act 1
        { 61, 15 }, { 62, 15 }, // Raspberry River Act 2
        { 65, 16 }, { 66, 16 }, // Thunder Turbine Act 1
        { 67, 17 }, { 68, 17 }, // Thunder Turbine Act 2
        { 69, 18 }, // Ending
    };

    string[,] Settings =
    {
        { "0", "Shappire Sights - Act 1", null },
        { "1", "Shappire Sights - Act 2", null },
        { "2", "Tropical Tracks - Act 1", null },
        { "3", "Tropical Tracks - Act 2", null },
        { "4", "Discount Districts - Act 1", null },
        { "5", "Discount Districts - Act 2", null },
        { "6", "Bubble Blossom - Act 1", null },
        { "7", "Bubble Blossom - Act 2", null },
        { "8", "Frozen Fountain - Act 1", null },
        { "9", "Frozen Fountain - Act 2", null },
        { "10", "Gusty Greenhouse - Act 1", null },
        { "11", "Gusty Greenhouse - Act 2", null },
        { "12", "Carnival Crater - Act 1", null },
        { "13", "Carnival Crater - Act 2", null },
        { "14", "Raspberry River - Act 1", null },
        { "15", "Raspberry River - Act 2", null },
        { "16", "Thunder Turbine - Act 1", null },
        { "17", "Thunder Turbine - Act 2", null },
    };
    for (int i = 0; i < Settings.GetLength(0); i++) settings.Add(Settings[i, 0], true, Settings[i, 1], Settings[i, 2]);
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
    if (current.Act == old.Act + 1)
        return settings[old.Act.ToString()];
}
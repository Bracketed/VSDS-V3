using YolusCORE;

namespace YolusCLI
{
    class Program
    {
        static void Main()
        {
            string[] luaFiles = Directory.GetFiles("/home/runner/work/VSDS-V3/VSDS-V3/source", "*.lua", SearchOption.AllDirectories);

            foreach (string file in luaFiles)
            {
                var SpecialFile = false;

                if (file.EndsWith("-NOOBFUSCATE.lua"))
                {
                    Console.WriteLine("Skipping " + file);
                    File.Move(file, file.Replace("-NOOBFUSCATE", ""));
                    continue;
                }

                if (file.EndsWith("init.lua"))
                {
                    SpecialFile = true;
                }

                var ObfuscationResult = Yolus.Obfuscate("", file, SpecialFile);
                if (!ObfuscationResult.Result.Success)
                {
                    Console.WriteLine("ERR: " + ObfuscationResult.Result.Error);
                    Environment.Exit(125);
                    return;
                }

                File.Delete("luac.out");
                File.Delete("t0.lua");
                File.Delete("t1.lua");
                File.Delete("t2.lua");
                File.Delete("t3.lua");
            }


            Console.WriteLine("Obfuscated all files successfully!");
        }
    }
}
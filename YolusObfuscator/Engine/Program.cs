using System.Diagnostics;
using System.Text;
using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;
using YolusCORE.Obfuscator;
using YolusCORE.Obfuscator.Control_Flow;
using YolusCORE.Obfuscator.Encryption;
using YolusCORE.Obfuscator.Generation;
using Figgle;

namespace YolusCORE
{
    public static class Yolus
    {
        private static Encoding _luaEncoder = Encoding.GetEncoding(28591);

        public class ObfuscationResult
        {
            public bool Success { get; set; }
            public string Error { get; set; }
        }

        public static async Task<ObfuscationResult> Obfuscate(string path, string input, bool isSpecialFile)
        {
            string OS = "/home/runner/work/VSDS-V3/VSDS-V3/.lua/bin/";
            ObfuscationSettings settings = new();
            DateTime CurrentDate = DateTime.Now;
            string ObfuscationID = Guid.NewGuid().ToString();
            ObfuscationResult result = new();

            try
            {
                result.Error = "";

                string l = Path.Combine(path, "luac.out");

                Process proc = new()
                {
                    StartInfo =
                    {
                        FileName = $"{OS}luac",
                        Arguments = "-o \"" + l + "\" \"" + input + "\"",
                        UseShellExecute = false,
                        RedirectStandardError = true,
                        RedirectStandardOutput = true
                    }
                };

                string err = "";

                proc.OutputDataReceived += (sender, args) => { err += args.Data; };
                proc.ErrorDataReceived += (sender, args) => { err += args.Data; };

                proc.Start();
                await proc.WaitForExitAsync();

                if (!(proc.ExitCode == 0))
                {
                    result.Error = "Engine failed at obfuscation stage 1, report at bracketed.co.uk/redirects/discord or bracketed.co.uk/redirects/virtua";
                    Console.WriteLine(proc.StandardError.ReadToEnd());
                    result.Success = false;
                    return result;
                }

                result.Error = err;

                if (!File.Exists(l))
                {
                    result.Error = "Failed to create obfuscated file.";
                    Console.WriteLine(err);
                    result.Success = false;
                    return result;
                }

                File.Delete(l);
                string t0 = Path.Combine(path, "t0.lua");

                proc = new Process
                {
                    StartInfo =
                           {
                               FileName = $"{OS}luajit",
                               Arguments =
                                   "../Lua/Minifier/luasrcdiet.lua --noopt-whitespace --noopt-emptylines --noopt-numbers --noopt-locals --noopt-strings --opt-comments \"" +
                                   input                                                       +
                                   "\" -o \""                                                  + t0 + "\"",
                               UseShellExecute        = false,
                               RedirectStandardError  = true,
                               RedirectStandardOutput = true
                           }
                };

                proc.OutputDataReceived += (sender, args) => { err += args.Data; };
                proc.ErrorDataReceived += (sender, args) => { err += args.Data; };

                proc.Start();
                await proc.WaitForExitAsync();

                if (!(proc.ExitCode == 0))
                {
                    result.Error = "Engine failed at obfuscation stage 2, report at bracketed.co.uk/redirects/discord or bracketed.co.uk/redirects/virtua";
                    Console.WriteLine(proc.StandardError.ReadToEnd());
                    result.Success = false;
                    return result;
                }

                result.Error = err;

                if (!File.Exists(t0))
                {
                    result.Error = "Failed to create obfuscated file.";
                    Console.WriteLine(err);
                    result.Success = false;
                    return result;
                }

                string t1 = Path.Combine(path, "t1.lua");

                File.WriteAllText(t1, new ConstantEncryption(settings, File.ReadAllText(t0, _luaEncoder)).EncryptStrings());
                proc = new Process
                {
                    StartInfo =
                           {
                               FileName  = $"{OS}luac",
                               Arguments = "-o \"" + l + "\" \"" + t1 + "\"",
                               UseShellExecute = false,
                               RedirectStandardError = true,
                               RedirectStandardOutput = true
                           }
                };

                proc.OutputDataReceived += (sender, args) => { err += args.Data; };
                proc.ErrorDataReceived += (sender, args) => { err += args.Data; };

                proc.Start();
                await proc.WaitForExitAsync();

                if (!(proc.ExitCode == 0))
                {
                    result.Error = "Engine failed at obfuscation stage 3, report at bracketed.co.uk/redirects/discord or bracketed.co.uk/redirects/virtua";
                    Console.WriteLine(proc.StandardError.ReadToEnd());
                    result.Success = false;
                    return result;
                }

                result.Error = err;

                if (!File.Exists(l))
                {
                    result.Error = "Failed to create obfuscated file.";
                    Console.WriteLine(err);
                    result.Success = false;
                    return result;
                }

                Deserializer des = new Deserializer(File.ReadAllBytes(l));
                Chunk lChunk = des.DecodeFile();

                if (settings.ControlFlow)
                {
                    CFContext cf = new(lChunk);
                    cf.DoChunks();
                }

                ObfuscationContext context = new ObfuscationContext(lChunk);

                string t2 = Path.Combine(path, "t2.lua");
                string c = new Generator(context).GenerateVM(settings);

                File.WriteAllText(t2, c, _luaEncoder);

                string t3 = Path.Combine(path, "t3.lua");

                proc = new Process
                {
                    StartInfo =
                           {
                               FileName = $"{OS}luajit",
                               Arguments =
                                   "../Lua/Minifier/luasrcdiet.lua --maximum --opt-entropy --opt-emptylines --opt-eols --opt-numbers --opt-whitespace --opt-locals --noopt-strings \"" +
                                   t2                                                                                                                                                +
                                   "\" -o \"" +
                                    t3 +
                                   "\""
                                ,
                           }
                };

                proc.Start();
                await proc.WaitForExitAsync();

                if (!(proc.ExitCode == 0))
                {
                    result.Error = "Engine failed at obfuscation stage 4, report at bracketed.co.uk/redirects/discord or bracketed.co.uk/redirects/virtua";
                    Console.WriteLine(proc.StandardError.ReadToEnd());
                    result.Success = false;
                    return result;
                }

                if (!File.Exists(t3))
                {
                    result.Error = "Failed to create obfuscated file.";
                    Console.WriteLine(err);
                    result.Success = false;
                    return result;
                }

                using FileStream FontSlantReliefStream = File.OpenRead("../Fonts/s-relief.flf");
                using FileStream Font3DStream = File.OpenRead("../Fonts/3-d.flf");
                using FileStream FontSmallSlantStream = File.OpenRead("../Fonts/smslant.flf");

                if (isSpecialFile == true)
                {
                    File.WriteAllText(Path.Combine(path, input), @$"--[[

{FiggleFontParser.Parse(FontSmallSlantStream).Render("Bracketed Scripting Utilities")}

  Team Bracketed Scripting Utilities 2024, keeping your scripts safe.
  This script uses a custom obfuscator, if you somehow crack it please DM me with any improvements to make!
  I'm always open to learning about insecurities in my obfuscator to learn how to make it better, DMing me would help a lot instead of leaking, thank you!

  Team Bracketed 2024
  Project Bracketed 2024
  Project Yolus Obfuscator 2024

  ninjaninja140, eledontlie and the rest of the team behind Project Bracketed thank you for using our obfuscator.
--]]

--[[

{FiggleFontParser.Parse(Font3DStream).Render("Virtua Electronics")}

  Virtua Electronics 2024
  The purpose of incorporating this obfuscated file into our system is solely to safeguard the integrity and security of our products. 
  Its primary function revolves around ensuring continuous and timely updates of our offerings. 
  We emphasize that this obfuscated file does not have malicious code or harmful elements. 
  The purpose of our obfuscation of files is a precautionary measure aimed at verifying the legitimacy of the software licenses associated with our products, guaranteeing that they are valid and up-to-date. 
  In essence, this security measure is implemented to maintain the trustworthiness and reliability of our products, prioritizing the safety and satisfaction of our users.

  Thank you for picking Virtua Electronics, our team thanks you for using our products.
--]]

--[[

{FiggleFontParser.Parse(FontSlantReliefStream).Render("Project Yolus Obfuscator")}

		Project Yolus Obfuscator by the Project Bracketed Team - Version 3.1.1
        Securing your scripts since 2023.
        
        Obfuscation Timestamp: {CurrentDate:dd/MM/yyyy} - {CurrentDate:HH:mm}
        Obfuscation ID: {ObfuscationID}
        Obfuscated by: @Github Actions (0)
        File: {input.Split("/").Last()}
--]]

" + File.ReadAllText(t3, _luaEncoder).Replace("\n", " "), _luaEncoder);
                }
                else
                {
                    File.WriteAllText(Path.Combine(path, input), @$"--[[

{FiggleFontParser.Parse(FontSlantReliefStream).Render("Project Yolus Obfuscator")}

		Project Yolus Obfuscator by the Project Bracketed Team - Version 3.1.1
        Securing your scripts since 2023.
        
        Obfuscation Timestamp: {CurrentDate:dd/MM/yyyy} - {CurrentDate:HH:mm}
        Obfuscation ID: {ObfuscationID}
        Obfuscated by: @Github Actions (0)
        File: {input.Split("/").Last()}
--]]

" + File.ReadAllText(t3, _luaEncoder).Replace("\n", " "), _luaEncoder);
                }

                result.Success = true;
                return result;
            }
            catch (Exception e)
            {
                result.Error = "Unknown error from within process.";
                Console.WriteLine(e);
                result.Success = false;
                return result;
            }
        }
    }
}

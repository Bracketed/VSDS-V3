using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Control_Flow.Types
{
	public static class Bounce
	{
		public static Random Random = new Random();
		public static CFGenerator CFGenerator = new CFGenerator();

		public static void DoInstructions(Chunk chunk, List<Instruction> Instructions)
		{
			Instructions = Instructions.ToList();
			foreach (Instruction l in Instructions)
			{
				if (l.OpCode != Opcode.Jmp)
					continue;

				Instruction First = CFGenerator.NextJMP(chunk, (Instruction)l.RefOperands[0]);
				chunk.Instructions.Add(First);
				l.RefOperands[0] = First;
			}

			chunk.UpdateMappings();
		}
	}
}
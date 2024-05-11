using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Control_Flow.Blocks
{
	public class Block
	{
		public Chunk Chunk;
		public List<Instruction> Body = new List<Instruction>();
		public Block Successor = null;

		public Block(Chunk c) =>
			Chunk = c;
	}
}
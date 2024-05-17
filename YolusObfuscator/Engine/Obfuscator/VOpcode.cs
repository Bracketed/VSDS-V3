using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator
{
	public abstract class VOpcode
	{
		public int VIndex;

		public abstract bool IsInstruction(Instruction instruction);
		public abstract string GetObfuscated(ObfuscationContext context);
		public virtual void Mutate(Instruction instruction) { }
	}
}
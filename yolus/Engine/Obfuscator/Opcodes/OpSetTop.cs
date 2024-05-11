using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	//custom VM opcode for inlining
	public class OpSetTop : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.SetTop;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Top=Inst[OP_A];";
	}
}
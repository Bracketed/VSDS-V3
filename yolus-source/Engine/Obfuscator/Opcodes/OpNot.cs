using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpNot : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.Not;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Stk[Inst[OP_A]]=(not Stk[Inst[OP_B]]);";
	}
}
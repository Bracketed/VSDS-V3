using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpSetUpval : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.SetUpval;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Upvalues[Inst[OP_B]]=Stk[Inst[OP_A]];";
	}
}
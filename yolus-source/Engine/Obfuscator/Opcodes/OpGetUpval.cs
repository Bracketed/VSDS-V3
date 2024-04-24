using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpGetUpval : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.GetUpval;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Stk[Inst[OP_A]]=Upvalues[Inst[OP_B]];";
	}
}
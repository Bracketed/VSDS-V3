using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpPushStk : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.PushStack;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Stk[Inst[OP_A]] = Stk";
	}
}
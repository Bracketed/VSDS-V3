using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpSetFEnv : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.SetFenv;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Env = Stk[Inst[OP_A]]";
	}
}
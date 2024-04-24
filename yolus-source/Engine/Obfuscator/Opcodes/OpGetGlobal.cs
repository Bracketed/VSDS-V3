using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpGetGlobal : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.GetGlobal;

		public override string GetObfuscated(ObfuscationContext context) =>
			"Stk[Inst[OP_A]]=Env[Const[Inst[OP_B]]];";

		public override void Mutate(Instruction instruction) =>
			instruction.B++;
	}
}
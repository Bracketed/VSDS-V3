using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpLoadNil : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.LoadNil;

		public override string GetObfuscated(ObfuscationContext context) =>
			"for Idx=Inst[OP_A],Inst[OP_B] do Stk[Idx]=nil;end;";
	}
}
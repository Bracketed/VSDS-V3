using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;

namespace YolusCORE.Obfuscator.Opcodes
{
	public class OpJmp : VOpcode
	{
		public override bool IsInstruction(Instruction instruction) =>
			instruction.OpCode == Opcode.Jmp;

		public override string GetObfuscated(ObfuscationContext context) =>
			"InstrPoint=InstrPoint+Inst[OP_B];";
	}
}
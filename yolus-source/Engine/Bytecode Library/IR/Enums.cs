namespace YolusCORE.BytecodeLibrary.IR
{
	public enum ConstantType
	{
		Nil,
		Boolean,
		Number,
		String
	}

	public enum InstructionType
	{
		ABC,
		ABx,
		AsBx,
		AsBxC,
		sAxBC,
		Data
	}
}
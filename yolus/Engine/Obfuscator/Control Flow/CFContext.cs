using YolusCORE.BytecodeLibrary.Bytecode;
using YolusCORE.BytecodeLibrary.IR;
using YolusCORE.Obfuscator.Control_Flow.Types;

namespace YolusCORE.Obfuscator.Control_Flow
{
	public class CFContext
	{
		public Chunk lChunk;

		public void DoChunk(Chunk c)
		{
			bool chunkHasCflow = false;

			Instruction CBegin = null;

			var Instructs = c.Instructions.ToList();
			for (var index = 0; index < Instructs.Count - 1; index++)
			{
				Instruction instr = Instructs[index];
				if (instr.OpCode == Opcode.GetGlobal && Instructs[index + 1].OpCode == Opcode.Call)
				{
					string str = ((Constant)instr.RefOperands[0]).Data.ToString();

					bool do_ = false;

					switch (str)
					{
						case "TBRACKETED_MAX_CFLOW_START":
							{
								CBegin = instr;
								do_ = true;
								chunkHasCflow = true;
								break;
							}
						case "TBRACKETED_MAX_CFLOW_END":
							{
								do_ = true;

								int cBegin = c.InstructionMap[CBegin];
								int cEnd = c.InstructionMap[instr];

								List<Instruction> nIns = c.Instructions.Skip(cBegin).Take(cEnd - cBegin).ToList();

								cBegin = c.InstructionMap[CBegin];
								cEnd = c.InstructionMap[instr];
								nIns = c.Instructions.Skip(cBegin).Take(cEnd - cBegin).ToList();
								TestSpam.DoInstructions(c, nIns);

								cBegin = c.InstructionMap[CBegin];
								cEnd = c.InstructionMap[instr];
								nIns = c.Instructions.Skip(cBegin).Take(cEnd - cBegin).ToList();
								Bounce.DoInstructions(c, nIns);

								cBegin = c.InstructionMap[CBegin];
								cEnd = c.InstructionMap[instr];
								nIns = c.Instructions.Skip(cBegin).Take(cEnd - cBegin).ToList();
								TestPreserve.DoInstructions(c, nIns);
								EQMutate.DoInstructions(c, c.Instructions.ToList());

								break;
							}
					}

					if (do_)
					{
						instr.OpCode = Opcode.Move;
						instr.A = 0;
						instr.B = 0;

						Instruction call = Instructs[index + 1];
						call.OpCode = Opcode.Move;
						call.A = 0;
						call.B = 0;
					}
				}
			}

			TestFlip.DoInstructions(c, c.Instructions.ToList());

			if (chunkHasCflow)
				c.Instructions.Insert(0, new Instruction(c, Opcode.NewStack));

			foreach (Chunk _c in c.Functions)
				DoChunk(_c);
		}

		public void DoChunks()
		{
			new Inlining(lChunk).DoChunks();
			DoChunk(lChunk);
		}

		public CFContext(Chunk lChunk_) =>
			lChunk = lChunk_;
	}
}
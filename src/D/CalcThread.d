module	CalcThread;

import	std.stdio;
import	std.process;
import	core.thread;

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
class	CCalcThread
{
	private
	{
		Thread		thread;
		int			thread_idx;
		string[]	cmd;
		string		train_path;
		int			qeue_size;

		void thread_func()
		{
			for (int i = 0; i < qeue_size; i++)
			{
				auto pipe = pipeProcess([train_path, cmd[i]], Redirect.stdout);
				scope(exit) wait(pipe.pid);

				string[] output;

				foreach(line; pipe.stdout.byLine) output ~= line.idup;
			}
		}
	}

	this()
	{
		this.thread		= new Thread(&this.thread_func);
		this.thread_idx	= 0;
		this.train_path	= "";
		this.qeue_size	= 0;
	}

	void start()
	{
		thread.start();
	}

	void init(string[] cmd_lines, int begin_idx, int end_idx, int thread_id, string train_path)
	{
		for (int i = begin_idx; i <= end_idx; i++)
		{
			cmd ~= cmd_lines[i];
		}

		qeue_size = cast(int) cmd.length;

		this.train_path = train_path;
	}
}
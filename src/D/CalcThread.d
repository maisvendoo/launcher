module	CalcThread;

import	std.stdio;
import	std.process;
import	std.format;
import	std.string;
import	std.conv;
import	core.thread;

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
class	CCalcThread
{
	private
	{
		Thread		thread;
		int			thread_id;
		string[]	cmd;
		string		train_path;
		string		results_path;
		int			qeue_size;
		int			begin_idx;
		int			end_idx;

		void thread_func()
		{
			string out_file_name = format("%s%s%d", results_path, "thread", thread_id);

			for (int i = 0; i < qeue_size; i++)
			{
				string log_file = format("--log_file=%s%d.log", results_path, begin_idx + i);

				string[] cmd_line;

				cmd_line ~= train_path;
				cmd_line ~= log_file;

				int len = cast(int) cmd[i].length;
				int idx = 0;
				string str = "";

				while (idx < len)
				{
					if (cmd[i][idx] != ' ')
						str ~= cmd[i][idx];

					if ( (cmd[i][idx] == ' ') && (str != "") || (idx == len-1) )
					{
						cmd_line ~= str;
						str = "";
					}

					idx++;
				}

				auto pipe = pipeProcess(cmd_line, Redirect.stdout);
				scope(exit) wait(pipe.pid);

				string[] output;

				foreach(line; pipe.stdout.byLine) output ~= line.idup;

				double train_mass = to!double(output[0]);
				double J = to!double(output[1]);
				double err = to!double(output[2]);
				double Tmax = to!double(output[3]);
				double Tmin = to!double(output[4]);

				File out_file = File(out_file_name, "a+");
				out_file.writefln("%d %g %g %g %g %g", begin_idx + i, train_mass, J, err, Tmax, Tmin);
				out_file.close();
			}
		}
	}

	this()
	{
		this.thread		= new Thread(&this.thread_func);
		this.thread_id	= 0;
		this.train_path	= "";
		this.qeue_size	= 0;
	}

	void start()
	{
		thread.start();
	}

	void init(string[] cmd_lines, int begin_idx, int end_idx, int thread_id, string train_path, string results_path)
	{
		for (int i = begin_idx; i <= end_idx; i++)
		{
			cmd ~= cmd_lines[i];
		}

		qeue_size = cast(int) cmd.length;

		this.train_path = train_path;
		this.results_path = results_path;

		this.begin_idx = begin_idx;
		this.end_idx = end_idx;

		this.thread_id = thread_id;
	}
}
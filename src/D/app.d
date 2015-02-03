//-------------------------------------------------------------------
//
//		Launcher for calculation with Train using
//		(c) maisvendoo, 2015/02/02
//
//-------------------------------------------------------------------
module	main;

import	std.stdio;
import	std.getopt;
import	std.string;

import	LuaScript;
import	common;
import	CalcThread;

private
{
	string[]		cmd_lines;
	string[]		input_data;
	TLauncherCmd	cmd_line;
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
void main(string[] args)
{
	// Read command line
	getopt(args,
		"config",		&cmd_line.cfg_file,
		"threads",		&cmd_line.threads,
		"train_path",	&cmd_line.train_path);

	// Analyze command line
	with (cmd_line)
	{
		if (cfg_file == "")
			cfg_file = "../../../launcher/cfg/test.lua";

		if (train_path == "")
			train_path = "./train";
	}

	// Read Lua-config
	CLuaScript lua_cfg = new CLuaScript();

	if (lua_cfg.exec_script(cmd_line.cfg_file) == -1)
	{
		writeln("FAIL: configuration not found");
		return;
	}

	int err = 0;

	int cmd_count = lua_cfg.get_int("cmd_count", err);
	string results_path = lua_cfg.get_string("results_path", err);
	int data_count = lua_cfg.get_int("data_count", err);

	for (int i = 0; i < data_count; i++)
	{
		input_data ~= lua_cfg.get_str_field("input_data", i, err);
	}

	string input_file_name = format("%sinput", results_path);

	File input_file = File(input_file_name, "wt");

	for (int i = 0; i < data_count; i++)
	{
		input_file.writeln(input_data[i]);
	}

	input_file.close();

	for (int i = 0; i < cmd_count; i++)
	{
		cmd_lines ~= lua_cfg.get_str_field("cmd_lines", i, err);
		//writeln(cmd_lines[i]);
	}

	int thread_tasks = cast(int) (cmd_count / cmd_line.threads);
	int mod = cmd_count - thread_tasks*cmd_line.threads;

	int task_count = cmd_count;
	int	i = 0;

	CCalcThread[] calc_thread = new CCalcThread[cmd_line.threads];

	while (task_count > mod)
	{
		calc_thread[i] = new CCalcThread();
		calc_thread[i].init(cmd_lines, i*thread_tasks, (i+1)*thread_tasks-1, i, 
			                cmd_line.train_path, results_path);
		calc_thread[i].start();

		i++;
		task_count -= thread_tasks;
	}

	if (mod > 0)
	{
		calc_thread[i-1] = new CCalcThread();
		calc_thread[i-1].init(cmd_lines, (i-1)*thread_tasks, cmd_count-1, i-1, 
			                  cmd_line.train_path, results_path);
		calc_thread[i-1].start();
	}
}
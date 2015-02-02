//-------------------------------------------------------------------
//
//		Common variables and structs
//		(c) maisvendoo, 2015/02/02
//
//-------------------------------------------------------------------
module	common;

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
struct	TLauncherCmd
{
	string		cfg_file;
	int			threads;
	string		train_path;

	this(this)
	{
		this.cfg_file	= "";
		this.threads	= 0;
		this.train_path	= "";
	}	
}
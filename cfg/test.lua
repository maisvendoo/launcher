---------------------------------------------------------------------
--
--    Test script for launcher control
--
---------------------------------------------------------------------

-- Default command line configuration

local default_cfg = 
{
    vehicles_num    = 70,
    railway_coord   = 1500,
    init_velocity   = 60,
    payload_coeff   = 1.0,
    delta           = 0.05,
    delta_eps       = -1.0,
    term_out        = false,
    log_file        = "Result"
}

-- Command lines array, reading from launcher

cmd_lines = {}

-- Fill cmd_lines table (this code writed by user)

local v_min   = 1.0
local v_max   = 120.0
local v_step  = 1.0

local nv_min  = 10
local nv_max  = 100
local nv_step = 5

local nv = nv_min
local v = v_min

local cmd_line = ""

-- Command lines count: accessable from launcher
cmd_count = 0

while (nv <= nv_max)
do
  
  v = v_min
  
  while (v <= v_max)
  do
    
    cmd_line = cmd_line .. " --vehicles=" .. nv
    cmd_line = cmd_line .. " --init_velocity=" .. v
    
    cmd_lines[cmd_count+1] = cmd_line
    
    cmd_count = cmd_count + 1
    
    v = v + v_step
    
  end
  
  nv = nv + nv_step
  
end
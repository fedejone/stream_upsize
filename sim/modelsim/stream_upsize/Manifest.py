action = "simulation"
sim_tool = "modelsim"
sim_top = "stream_upsize_tb"

sim_post_cmd = "vsim -voptargs=+acc -do wave.do -i stream_upsize_tb"

modules = {
  "local" : [ "../../../tb/stream_upsize_tb" ],
}

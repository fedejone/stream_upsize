target = "xilinx"
action = "synthesis"

syn_family = "KINTEX-7"
syn_device = "xc7k325t"
syn_grade = "-2"
syn_package = "ffg676"
syn_top = "stream_upsize"
syn_project = "stream_upsize"
syn_tool = "vivado"
language = "verilog"

syn_properties = [
    ["steps.synth_design.args.more options", "-verbose"],
    ["steps.synth_design.args.retiming", "1"],
    ["steps.synth_design.args.assert", "1"],
    ["steps.opt_design.args.verbose", "1"],
    ["steps.opt_design.args.directive", "Explore"],
    ["steps.opt_design.is_enabled", "1"],
    ["steps.place_design.args.directive", "Explore"],
    ["steps.place_design.args.more options", "-verbose"],
    ["steps.phys_opt_design.args.directive", "AlternateFlowWithRetiming"],
    ["steps.phys_opt_design.args.more options", "-verbose"],
    ["steps.phys_opt_design.is_enabled", "1"],
    ["steps.route_design.args.directive", "Explore"],
    ["steps.route_design.args.more options", "-verbose"],
    ["steps.post_route_phys_opt_design.args.directive", "AddRetime"],
    ["steps.post_route_phys_opt_design.args.more options", "-verbose"],
    ["steps.post_route_phys_opt_design.is_enabled", "1"],
    ["steps.write_bitstream.args.verbose", "1"]]

modules = {
  "local" :[ "../../rtl"
 ]
}


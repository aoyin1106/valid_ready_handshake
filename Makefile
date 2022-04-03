proj = handshake
tb = testbench
VERILOG_SRCS = src/*.v

.PHONY: build-project
$(vivado_proj_file) build-project: $(VERILOG_SRCS)
		vivado -mode batch -source scripts/build_project.tcl -tclargs $(proj)

.PHONY: sim
sim: $(vivado_proj_file)
		vivado -mode batch -source scripts/sim.tcl -tclargs $(proj) $(tb)

.PHONY: clean
clean:
		rm -rf *.log *.jou *.str *.tar
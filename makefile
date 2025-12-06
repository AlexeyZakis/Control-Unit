VERILOG_COMPILER = iverilog
SIMULATOR = gtkwave

OUTPUT = main
DUMP_FILE = dump.vcd

SOURCES = main.v datapath.v test.v

run: 
	$(VERILOG_COMPILER) $(SOURCES) -o $(OUTPUT)
	./$(OUTPUT)
	$(SIMULATOR) $(DUMP_FILE)
	

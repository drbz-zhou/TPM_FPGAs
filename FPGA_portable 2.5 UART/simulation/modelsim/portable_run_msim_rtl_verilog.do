transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/UARTCTL.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/uart.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/portable.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/spi.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/ADCCTL.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/portable_shell.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/SCANCTL.v}
vlog -vlog01compat -work work +incdir+C:/Users/Heber/Documents/TU\ Kaiserslautern/second\ semester/job/FPGA_portable {C:/Users/Heber/Documents/TU Kaiserslautern/second semester/job/FPGA_portable/MUX_DECODER.v}
vlib pll
vmap pll pll
vlog -vlog01compat -work pll +incdir+c:/users/heber/documents/tu\ kaiserslautern/second\ semester/job/fpga_portable/db/ip/pll {c:/users/heber/documents/tu kaiserslautern/second semester/job/fpga_portable/db/ip/pll/pll.v}
vlog -vlog01compat -work pll +incdir+c:/users/heber/documents/tu\ kaiserslautern/second\ semester/job/fpga_portable/db/ip/pll/submodules {c:/users/heber/documents/tu kaiserslautern/second semester/job/fpga_portable/db/ip/pll/submodules/altera_reset_controller.v}
vlog -vlog01compat -work pll +incdir+c:/users/heber/documents/tu\ kaiserslautern/second\ semester/job/fpga_portable/db/ip/pll/submodules {c:/users/heber/documents/tu kaiserslautern/second semester/job/fpga_portable/db/ip/pll/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work pll +incdir+c:/users/heber/documents/tu\ kaiserslautern/second\ semester/job/fpga_portable/db/ip/pll/submodules {c:/users/heber/documents/tu kaiserslautern/second semester/job/fpga_portable/db/ip/pll/submodules/pll_altpll_0.v}
vlog -vlog01compat -work pll +incdir+c:/users/heber/documents/tu\ kaiserslautern/second\ semester/job/fpga_portable/db/ip/pll/submodules {c:/users/heber/documents/tu kaiserslautern/second semester/job/fpga_portable/db/ip/pll/submodules/pll_altpll_1.v}


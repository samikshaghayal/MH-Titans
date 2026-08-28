## CLOCK
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin [get_ports clk]


## INPUTS

## RESET
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PACKAGE_PIN C12 [get_ports reset]

## SW0 - Route A Request
set_property IOSTANDARD LVCMOS33 [get_ports route_a_req]
set_property PACKAGE_PIN J15 [get_ports route_a_req]

## SW1 - Route B Request
set_property IOSTANDARD LVCMOS33 [get_ports route_b_req]
set_property PACKAGE_PIN L16 [get_ports route_b_req]

## SW2 - Emergency Request
set_property IOSTANDARD LVCMOS33 [get_ports emergency_req]
set_property PACKAGE_PIN M13 [get_ports emergency_req]

## SW3 - Track Clear
set_property IOSTANDARD LVCMOS33 [get_ports track_clear]
set_property PACKAGE_PIN R15 [get_ports track_clear]


## OUTPUTS

## LED0 - Route A Green
set_property IOSTANDARD LVCMOS33 [get_ports route_a_green]
set_property PACKAGE_PIN H17 [get_ports route_a_green]

## LED1 - Route B Green
set_property IOSTANDARD LVCMOS33 [get_ports route_b_green]
set_property PACKAGE_PIN K15 [get_ports route_b_green]

## LED2 - Emergency Green
set_property IOSTANDARD LVCMOS33 [get_ports emergency_green]
set_property PACKAGE_PIN J13 [get_ports emergency_green]

## LED3 - Route A Red
set_property IOSTANDARD LVCMOS33 [get_ports route_a_red]
set_property PACKAGE_PIN N14 [get_ports route_a_red]

## LED4 - Route B Red
set_property IOSTANDARD LVCMOS33 [get_ports route_b_red]
set_property PACKAGE_PIN R18 [get_ports route_b_red]

## LED5 - Emergency Red
set_property IOSTANDARD LVCMOS33 [get_ports emergency_red]
set_property PACKAGE_PIN V17 [get_ports emergency_red]

## LED6 - System Fault
set_property IOSTANDARD LVCMOS33 [get_ports system_fault]
set_property PACKAGE_PIN U17 [get_ports system_fault]

## LED7 - Fault Blink
set_property IOSTANDARD LVCMOS33 [get_ports fault_blink]
set_property PACKAGE_PIN U16 [get_ports fault_blink]

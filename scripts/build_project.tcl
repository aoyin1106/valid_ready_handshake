set project_name [lindex $argv 0]

set sources_file scripts/${project_name}.tcl

if {![file exists $sources_file]} {
    puts "Invalid project name!"
    exit
}

create_project -force ${project_name}_proj ${project_name}_proj -part xc7a35tcpg236-1
set_property board_part digilentinc.com:basys3:part0:1.1 [current_project]

source $sources_file

# Add lib file

update_compile_order -fileset sources_1

check_syntax

update_compile_order -fileset sources_1


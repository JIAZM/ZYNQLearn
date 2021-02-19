#!/bin/bash

# echo Usage...
# echo "first parameter:<project name | command>"
# echo "command:"
# echo -e "\tclean  com"
# echo '$1:'$1

if [ "$1" = "" ]; then
	echo Usage...
	echo "first parameter:<project name | command>"
	echo "command:"
	echo -e "\tclean  com"
	exit
else
	read -p "Project name: " pname
fi

case $1 in
	"")	echo -e "No param input"
		exit;;
	"clean")	rm ${pname}.lxt ${pname}.vvp ${pname} 2> /dev/null
		exit;;
	"com")	echo Synthesize...;;
esac


echo iverilog compiling...
iverilog ${pname}.v ${pname}_tb.v -o ${pname}.vvp
if [ $? -ne 0 ]; then
	echo iverilog synthesize failed
	exit
fi
echo vvp...
vvp -n $pname.vvp -lxt
if [ $? -ne 0 ]; then
	echo $?
	echo vvp failed
	exit
fi
gtkwave $pname.lxt

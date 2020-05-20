# making this change to avoid makefile from exiting on error from elf2hex because width is bigger than 128
sed -i -e 's/ELF2HEX := elf2hex/ELF2HEX := - elf2hex/g' $1
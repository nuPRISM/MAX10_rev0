source do_get_project_settings.cmd

export PATH_TO_64BIT=`cygpath -u $QUARTUS_ROOTDIR/bin64`

echo "Path = " $PATH
echo "PATH_TO_64BIT = " $PATH_TO_64BIT
if [[ ":$PATH:" == *":$PATH_TO_64BIT:"* ]]; then
     echo "Path already contains 64bit path!"
else
     echo "adding 64bit path to Quartus..."
     export PATH=`cygpath -u $QUARTUS_ROOTDIR/bin64`:$PATH
fi
	 
echo on
echo "Now compiling Stratix IV Quartus project..."
quartus_sh "$@" --flow compile ${quartus_project_location_directory}/${main_fpga_project_filename_base}
cp -f --backup ${quartus_project_postcompile_sof_location_directory}/${main_fpga_project_filename_base}\.${main_fpga_project_programming_file_extension} ../exe/

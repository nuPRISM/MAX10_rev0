source do_get_project_settings.cmd
source ../../../tsbs/common_scripts_library/tsb/ip/scripts/get_relative_path.sh
cd ../exe
exe_dir=$(pwd)
cd -
cd ${quartus_project_location_directory}/
project_dir=$(pwd)
relative_path=$(get_relative_path ${project_dir} ${exe_dir})
cd -
source convert_sof_to_rbf.cmd ../exe/${main_fpga_project_filename_base}

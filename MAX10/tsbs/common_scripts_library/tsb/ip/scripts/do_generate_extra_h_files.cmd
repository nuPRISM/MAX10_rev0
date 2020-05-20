source do_get_project_settings.cmd
rm -rf ../rtl/${home_dir_for_extra_h_files}/extra_h_files
mkdir ../rtl/${home_dir_for_extra_h_files}/extra_h_files
sopc-create-header-files ../rtl/${main_qsys_base_filename}.sopcinfo --output-dir ../rtl/${home_dir_for_extra_h_files}/extra_h_files "$@"
# sopc-create-header-files ../rtl/${main_qsys_base_filename}.sopcinfo --single  ../rtl/${home_dir_for_extra_h_files}/extra_h_files/${single_master_h_filename} --module ${single_master_h_module_name} --single-prefix ${single_master_h_prefix} "$@"

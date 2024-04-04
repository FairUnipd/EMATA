function full_cmd = get_fsl_command(cmd)


FSL_PATH = fileread('fsl_settings.txt');

FSL_CONFIG_PATH = [FSL_PATH,'/etc/fslconf/fsl.sh'];

path_cmd       = [FSL_PATH,'/bin/',cmd];
full_cmd        = ['LD_LIBRARY_PATH=; . ' FSL_CONFIG_PATH '; ' path_cmd];

function options = get_options(options_path)

options_text = fileread(options_path);
options      = jsondecode(options_text);



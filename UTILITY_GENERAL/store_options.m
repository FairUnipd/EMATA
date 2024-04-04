function store_options(options,qc_path)


options_text = jsonencode(options);


fID = fopen(fullfile(qc_path, 'options.json'), 'w');

fprintf(fID,options_text);
fclose(fID);
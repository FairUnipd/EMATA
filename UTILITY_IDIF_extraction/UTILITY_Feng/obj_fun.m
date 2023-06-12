function [ obj_fun ] = obj_fun( par, struct )

    AIF = my_model( par, struct );
    
    obj_fun = (struct.data - AIF).*struct.W;

end
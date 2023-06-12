function [ AIF ] = my_model( par, struct )

A2 = par(1);
A3 = par(2);
lambda1 = par(3);
lambda2 = par(4);
lambda3 = par(5);

A1 = struct.A1;
t = struct.t;

% MODELLO (Concentrazione voxel arteriale)
AIF = (A1-A2-A3).*exp(-lambda1*(t-t(1)))+A2*exp(-lambda2*(t-t(1)))+A3*exp(-lambda3*(t-t(1)));

end
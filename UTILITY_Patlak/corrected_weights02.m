function [w] = corrected_weights02(TAC, t_PET_delta)
%CORRECTED_WEIGHTS Creates the weigths to use in WNLLS
%   time in seconds

% CREO SD DATI E LA CORREGGO
idx = find(t_PET_delta == t_PET_delta(2));

temp              = 1./(sqrt(TAC./t_PET_delta))';
temp_iniziale     = temp(1:idx(end));
temp(1:idx(end))  = temp_iniziale(end)+0*temp_iniziale;
temp(isnan(temp)) = 0;
w = temp;

end
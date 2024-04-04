function [IDIF_corrected, rc, m_tb] = chen_correction(IDIF, IDIF_time, venous, venous_time, Ct, Ct_time)
%It performs Chen correction to IDIF 
%
% Chen et al., (1998). 
% Noninvasive quantification of the cerebral metabolic rate for glucose 
% using positron emission tomography, 18F-fluoro-2-deoxyglucose, the Patlak
% method, and an image-derived input function. 
% Journal of Cerebral Blood Flow & Metabolism, 18(7), 716-723.
%
%INPUT: 
%IDIF
%IDIF_time
%
%venous = venous Cp (Bq/ml)
%venous_time = time (sec)
%
%Ct: surrounding tissue activity
%Ctime: tissue activity time grid
%
%OUTPUT:
%IDIF_corrected
%
%rc: Recovery Coefficient
%m_tb: Spillover coefficient

%Written by MDF, 10/21/2022

grid            = venous_time;
venous_counts   = venous;

Ct_interp       = interp1(Ct_time, Ct, grid,'linear','extrap');
IDIF_interp     = interp1(IDIF_time, IDIF, grid,'linear','extrap');

% Prepare design matrix and outcome for multilinear regression
X                       = [venous_counts' Ct_interp'];
Y                       = IDIF_interp';
par                     = inv(X'*X)*X'*Y;

% Coefficients must be non-negative!
rc                      = par(1); % recovery coefficient
m_tb                    = par(2); % spillover coefficient

% Correction of IDIF with estimated coefficients
Ct_interp_fit                  = interp1(Ct_time, Ct, IDIF_time);
IDIF_corrected                 = (IDIF - m_tb*Ct_interp_fit)./rc;


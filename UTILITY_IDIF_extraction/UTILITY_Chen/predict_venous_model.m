function model_fit = predict_venous_model(t_fit,covariates)
% Predict FDG venous radiotracer concentration from subject's covariates,
% 
% Volpi T et al., Modeling venous plasma samples in [18F] FDG PET studies: a nonlinear mixed-effects approach.
% Annu Int Conf IEEE Eng Med Biol Soc. 2022 Jul;2022:4704-4707. doi: 10.1109/EMBC48229.2022.9871429. PMID: 36086500.
%
%INPUT
%t_fit: time grid (sec)
%covariates: 
%   covariates(1) = SEX (0 = male, 1 = female)
%   covariates(2) = BSA (m^2, obtained using Dubois formula 
%       --> dubois=@(h,w) (0.007184 *h.^(0.725).*(w.^(0.425))); 
%               h = height(cm), w = weigth (kg))
%   covariates(3) = AGE (years)
%   covariates(4) = DOSE (KBq/ml)
%
%OUTPUT
%model fit: struct containing fitted curve (fit) and t_fit

%Written by MDF, 10/21/2022

%% Setting model parameters

t_fit = t_fit / 60;

theta1              = 9.83;
theta2              = 0.018;
beta_theta1_SEX     = 1.18; 
beta_theta1_BSA     = -3.57;
%beta_theta1_DOSE    = 0.0257;
beta_theta2_DOSE    = -0.0035;%-5.76e-05;
beta_theta2_AGE     = 2.7e-6;

%% Centering covariates with respect to training data mean values
%mean_covariates     = [0 2.2325 55.2593 0];
mean_covariates     = [0 2.2325 55.2593 5.0731*37];
%mean_covariates     = [0 1.84 61 206.6]; %onco
covariates_centered = (covariates - mean_covariates);

%% Model prediction 

psi1 = theta1 + beta_theta1_SEX*covariates_centered(1) + beta_theta1_BSA*covariates_centered(2); %+ beta_theta1_DOSE*covariates_centered(4);
psi2 = theta2 + beta_theta2_AGE*covariates_centered(3) + beta_theta2_DOSE*covariates_centered(4)/37;


model_fit.c = psi1*exp(-psi2*t_fit);
model_fit.t = t_fit*60;
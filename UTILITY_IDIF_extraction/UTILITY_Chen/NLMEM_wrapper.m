function model_fit = NLMEM_wrapper(covariates, t_fit, qc_path, out_path)

covar(1) = covariates(1); %Sex

hh = covariates(2); %Height
ww = covariates(3); %Weight

covar(2) = (0.007184 *hh.^(0.725).*(ww.^(0.425)));
covar(3) = covariates(4); %Age
covar(4) = covariates(5); %Dose

model_fit = predict_venous_model(t_fit,covar);

figure('visible','off')
plot(t_fit/60, model_fit.c,'LineWidth',2)
xlabel('time [min]')
ylabel('Activity [KBq/ml]')
exportgraphics(gca,fullfile(qc_path,'NLMEM_venous_FIT.jpg'))
grid on

save(fullfile(out_path,'Venous_NLMEM_FIT.mat'),'model_fit');


end
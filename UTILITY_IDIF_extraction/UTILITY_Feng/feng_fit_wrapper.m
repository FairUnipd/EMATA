function Feng_fit = feng_fit_wrapper(IDIF_path, qc_path, anatomy, options)

if nargin<6

    options = get_default_options();

end

load(fullfile(IDIF_path,['IDIF_' anatomy '.mat']),'IDIF');

IDIF_raw    = IDIF.IDIF_raw;
t_IDIF_emi   = IDIF.t_IDIF_raw;
t_IDIF_delta = IDIF.t_IDIF_delta;

%%%%%%%
%%Fit%%
%%%%%%%

%setting initial conditions
switch (anatomy)

    case 'ICA'

        par = options.ICA_priors';

    case 'CCA'

        par = options.CCA_priors';


end

[AIF_v, t_IDIF_virtual,~,p_est,cv_est,rho2,W]=feng_fitting(IDIF_raw,t_IDIF_emi,t_IDIF_delta, 'obj_fun',par);

%%%%%%%%%%%%%
%%Plot IDIF%%
%%%%%%%%%%%%%

figure('visible','off')
subplot(221)
plot(t_IDIF_emi/60, IDIF_raw)
hold on
plot(t_IDIF_virtual, AIF_v, '-r')
xlim([0,2850/60])
xlabel('time [min]')
ylabel('Activity [Bq/ml]')
subplot(222)
plot(t_IDIF_emi/60, IDIF_raw)
hold on
plot(t_IDIF_virtual, AIF_v, '-r')
xlim([0,210/60])
xlabel('time [min]','FontSize',12)
ylabel('Activity [Bq/ml]','FontSize',12)

AIF_v2 = interp1(t_IDIF_virtual, AIF_v, t_IDIF_emi/60);
res2 = (IDIF_raw - AIF_v2).*W/max(IDIF_raw);
nr2 = res2./sqrt(rho2);

N = length(nr2);
t_res = t_IDIF_emi/60;
subplot(223)
plot(t_res,nr2,'o-',t_res,zeros(N,1),'--r',t_res,ones(N,1),'-.r',t_res,-ones(N,1),'-.r')
xlim([0,2850/60])
ylim([-2 2])
xlabel('time [min]','FontSize',12)
ylabel('Weighted Residuals [u.a.]','FontSize',12)

subplot(224)
plot(t_res,nr2,'o-',t_res,zeros(N,1),'--r',t_res,ones(N,1),'-.r',t_res,-ones(N,1),'-.r')
xlim([0,210/60])
ylim([-2 2])
xlabel('time [min]','FontSize',12)
ylabel('Weighted Residuals [u.a.]','FontSize',12)



exportgraphics(gcf, fullfile(qc_path,['Feng_Fit_',anatomy,'.jpeg']),'Resolution',300)

%%%%%%%%%%%%%%
%%Saving FIT%%
%%%%%%%%%%%%%%

Feng_fit.par           = p_est;
Feng_fit.cv            = cv_est;
Feng_fit.IDIF_fit      = AIF_v;
Feng_fit.t_IDIF_fit    = t_IDIF_virtual*60;


IDIF.IDIF   = Feng_fit.IDIF_fit;
IDIF.t_IDIF = Feng_fit.t_IDIF_fit;

IDIF.Feng_fit   = Feng_fit;
IDIF.flag_Feng  = 1;
IDIF.flag_Chen  = 0;


save(fullfile(IDIF_path,['IDIF_',anatomy,'.mat']),'IDIF');
store_options(options,qc_path);




end
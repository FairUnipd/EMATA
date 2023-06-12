function Chen_correction_wrapper(venous, venous_time, IDIF_path, BG_path, qc_path, anatomy)


load(fullfile(IDIF_path,['IDIF_' anatomy '.mat']));
load(fullfile(BG_path,['BG_' anatomy '.mat']));

IDIF_uncorrected        = IDIF.IDIF;
IDIF_uncorrected_time   = IDIF.t_IDIF;


if IDIF.flag_Chen == 1

    if IDIF.flag_Feng == 1

        IDIF_uncorrected        = IDIF.Feng_fit.IDIF_fit;
        IDIF_uncorrected_time   = IDIF.Feng_fit.t_IDIF_fit;

    else

        IDIF_uncorrected        = IDIF.IDIF_raw;
        IDIF_uncorrected_time   = IDIF.t_IDIF_raw;

    end

end

Ct      = centroids_bg(:,3)';
Ct_time = time_bg;
[IDIF_corrected,rc,sp] = chen_correction(IDIF_uncorrected,IDIF_uncorrected_time, venous,venous_time, Ct, Ct_time);

figure('visible','off')
figure
plot(IDIF.t_IDIF/60,IDIF_corrected, 'LineWidth',2)
hold on
plot(IDIF_uncorrected_time/60,IDIF_uncorrected,'LineWidth',2)
plot(venous_time/60,venous,'LineWidth',2)
plot(Ct_time/60,Ct,'LineWidth',2)
grid on
legend({'IDIF corrected','IDIF uncorrected','venous','Ct (spillover)'})
xlabel('time [min]')
ylabel('Activity [Bq/ml]')

savefig(fullfile(qc_path,['Chen_correction_' anatomy '_QC.fig']));
exportgraphics(gca,fullfile(qc_path,['Chen_correction_' anatomy '_QC.jpg']));

IDIF.flag_Chen          = 1;
IDIF.IDIF               = IDIF_corrected;

IDIF.Chen_fit.rc        = rc;
IDIF.Chen_fit.sp        = sp;
IDIF.Chen_fit.Ct        = Ct;
IDIF.Chen_fit.Ct_time   = Ct_time;

save(fullfile(IDIF_path,['IDIF_',anatomy,'.mat']),'IDIF');




end
function[AIF_v, t_IDIF_virtual,par_names,p_est,cv_est,rho2,W] = feng_fitting(IDIF_raw,t_IDIF_emi,t_IDIF_delta, obj_fun_choice, par)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIT del modello sulla IDIF %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t_fit       = t_IDIF_emi/60;
%t_fit_delta = t_IDIF_delta/60;
t_end       = t_IDIF_emi(end)/60; %t_PET_emi

[A1, index_peak] = max(IDIF_raw);
IDIF_fit         = IDIF_raw/A1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIMA PARTE DEL SEGANLE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

IDIF_init   = IDIF_fit(1:index_peak);
t_peak      = t_fit(index_peak);


% Trovo il primo campione che � sufficientemente diverso da zero
n = 1;
while IDIF_init(n) < 0.1*IDIF_init(end)
    n = n+1;
end
index_start = n-1;

if index_start <= 0

    index_start = 1;

end

% REGRESSIONE LINEARE
T = t_fit(index_start:index_peak)';
X = IDIF_init(index_start:index_peak)';
t_fit_virtual_initial = t_fit(1):1/60:T(end);


%LLS
X = [X ones(length(X),1)];

% Impongo passaggio della retta per il picco
w       = ones(length(X),1);
w(end)  = 1000;
W       = diag(w);

mq = (W*X)\(w.*T);

t_start_virtual = round(mq(2)*60)/60;


AIF_1 = max(zeros(1, length(t_fit_virtual_initial)), (A1/A1)/(t_peak-t_start_virtual).*(t_fit_virtual_initial-t_start_virtual));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECONDA PARTE DEL SEGNALE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inizializzo parametri da passare a lsqnonlin
struct.A1 = A1/A1;

B = sqrt(1./t_IDIF_delta);
W = 1./B;

struct.data = IDIF_fit(index_peak:end);
struct.t    = t_fit(index_peak:end);
struct.W    = W(index_peak:end);
struct.tp   = t_fit(index_peak);

p_0     = par;
pup     = p_0*10;
pdown   = p_0/10;
options = optimset('Display','off','TolFun',1e-5);

% Chiamo lsqnonlin
[p_est,RESNORM,RESIDUAL,~,~,~,J] = lsqnonlin(obj_fun_choice,par,pdown,pup,options,struct);

% PRECISIONE DELLE STIME
WRSS = RESNORM;
N = length(struct.t);
rho2 = WRSS/(N-length(p_est));

jac = full(J);
cov = inv(jac'*jac)*rho2;
sd_est = sqrt(diag(cov));
cv_est = 100*sd_est./p_est;

% RESIDUI PESATI E NORMALIZZATI
wr = RESIDUAL;
nr = wr./sqrt(rho2);

% Modello della IDIF con i parametri stimati da lsqnonlin su griglia virtuale
struct.t = struct.tp:1/60:t_end(end);
AIF_2 = my_model( p_est, struct );

%%%%%%%%%%%%%%%%%%%%
% UNIONE DUE PARTI %
%%%%%%%%%%%%%%%%%%%%

t_IDIF_virtual = t_fit(1):1/60:struct.t(end);%is it right rather than t_end(end)
AIF_v = [AIF_1(1:end-1) AIF_2];
AIF_v = AIF_v*A1;

% save fitting results in table
par_names =  ["A2"; "A3"; "lambda1"; "lambda2"; "lambda3"];


end
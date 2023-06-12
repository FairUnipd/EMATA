function [Kp stdKp] = Patlak(tissue,time_tissue,Cp,Cpint,weights,nrpoints)
% NOTA IMPORTANTE
%Cp e Cpint devono essere interpolati sulla griglia dei tempi definita da
%time_tissue

% Cp = interp1(tnew,Cpnew,time);
% Cplint = cumtrapz(tnew,Cpnew);
% Cpint = interp1(tnew,Cplint,time);
% nrpoints = 10;

%Check sul numero di dati totali e numero di dati per Patlak
ts=time_tissue;
N=length(ts);
if (N/2)<=nrpoints
    nrpoints=round(N/2)-1;
end

%Check sui dati (controllo negatività)
for i=1:N
    if tissue(i)<0
        tissue(i)=0;
        weights(i)=0;
    end
end
%Inizializzazione Patlak
np = 2;
TAC = tissue;
IB12 = weights(N-nrpoints+1:N);

%Patlak
if ~any(TAC)
    Kp=0;
    stdKp=0;
else
        
    W = diag(IB12);
    %tacint  = cumtrapz(ts,TAC);
    Y       = TAC(N-nrpoints+1:N)./Cp(N-nrpoints+1:N);
    X       = [Cpint(N-nrpoints+1:N)./Cp(N-nrpoints+1:N) ones(nrpoints,1)];
    P       = inv(X'*W*X)*X'*W*Y;
    resid   = (Y-X*P)'*W*(Y-X*P);
    gamma   = resid/(N-np);
    Cov     = gamma*inv(X'*W*X);
    
    
    StDev=sqrt(diag(Cov));
    
    %CV_P=100*abs(StDev./P);
    Kp =   P(1);
    stdKp=StDev(1);
    
%     %%Graphic
%     figure(3)
%     plot(X(:,1),Y,'or')
%     hold on
%     plot(X(:,1),(P(1)*X(:,1)+P(2)),'.-b')
%     hold off
%     pause(0.3)
   
    
    
end

end

%-------------------------------------------------------------------------
%Provided by Gaia Rizzo, Padova University
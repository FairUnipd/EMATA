function [Cp,Cpint,time,TAC_extended,weights]=setPatlak(plasma,plasma_time,time,TAC_extended,weights) %reference
%Check Plasma
t_Cp=plasma_time;
Cp=plasma;
if t_Cp(1)~=0
    t_Cp=[0;t_Cp];
    Cp=[0;Cp];
end
%Check Tissue
if time(1)~=0
    %DIM=size(TAC_extended);
    temp=zeros(length(TAC_extended)+1,1);
    for f=1:length(TAC_extended)
        temp(f+1,:)=TAC_extended(f,:);
    end
    TAC_extended=temp;
    time=[0;time];
    max_w=max(weights);
    weights=[max_w;weights];
    %reference=[0;reference];
end

%Check shortest time grid
time=time./60; %Conversione finale minuti
t_Cp=t_Cp./60;
if time(end)>t_Cp(end)
    t_Cp=[t_Cp;time(end)];
    last=Cp(end); %prolungo costantemente il plasma
    Cp=[Cp;last];
end
tv=0:0.5:time(end);
tv=tv';
Cpv=interp1(t_Cp,Cp,tv);
Cplint = cumtrapz(tv,Cpv);

%Segnali Utili
Cpint = interp1(tv,Cplint,time);
Cp= interp1(t_Cp,Cp,time);


% figure
% plot(time,Cp,'.r--',time,reference,'ko');
% title('Parent Plasma and Tissue TAC comparison');
% xlabel('Time [xx]');
% ylabel('Activity [xx]');

end


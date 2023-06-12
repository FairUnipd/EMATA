function [ npoints ] = chosePointsForPatlak( tissue,Cp,Cpint )
if ~any(tissue)
    npoints=8;
    disp('   !!! WRN: NO TACs found in IDWC FILE!!!')
    disp('   !!! WRN: PATLAK SETS as DEFAULT [8 samples]');
else
X=Cpint./Cp;
Y=tissue./Cp;
[m,i]=max(Cp);

figure
plot(X(end-10:end),Y(end-10:end),'*');
hold on

title('Selection of Patlak Data')
xlabel('int Cp / Cp');
ylabel('TAC /Cp');


% prompt = {'Number of Point for Patlak Analysis:'};
% dlg_title = 'PATLAK ANALYSIS';
% num_lines = 1;
% def = {'8'};
% answer = inputdlg(prompt,dlg_title,num_lines,def);
% 
% npoints=str2num(cell2mat(answer));

npoints=7;
end

end


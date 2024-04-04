function path = convertpath2lnx(path)

if ispc %windows

    %converting PATH
    [~,cmdout] = system(['wsl wslpath "' path '"']);
    path       = cmdout(1:end-1); %to eliminate space

end


end
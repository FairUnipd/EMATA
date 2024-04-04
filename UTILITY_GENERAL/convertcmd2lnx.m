function cmd = convertcmd2lnx(cmd)

if ispc %windows
    %converting command
    cmd = ['bash -c "' cmd '"'];
end

end
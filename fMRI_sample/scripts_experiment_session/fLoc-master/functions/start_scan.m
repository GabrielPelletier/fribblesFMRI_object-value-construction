function [status, start_time] = start_scan
% This code will wait for the Trigger from the scanner to start the
% experiment. Same as Keyboard Input 't'.

try
    s = serial('/dev/tty.usbmodem12341', 'BaudRate', 57600);
    fopen(s);
    fprintf(s, '[t]');
    fclose(s);
catch
    err
end

if exist('err','var') == 0
    start_time  = GetSecs;
    status = 0;
else
    start_time = GetSecs;
    status = 1;
end

end

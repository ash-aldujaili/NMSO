
% run demo for 2-D
NMSO(0,0,0,0,0,0,2);
pause(2);
% run demo for 1-D
NMSO(0,0,0,0,0,0,1);
% practical problem
NMSO(0,@(x) sum((x-0.727465).^2),10,1000,5,-5,0);
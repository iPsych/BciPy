set(0,'DefaultFigureWindowStyle', 'docked')
close all
clear
clc

pFilt = [-8.77803102407428e-05,-0.00189352391427887,-0.00354614862967617,-0.00482644914994822,-0.00461049309823788,-0.00292541015225790,-0.000999016197721182,-0.000458439212884342,-0.00196731602169841,-0.00448978288166562,-0.00599480913680623,-0.00517769037381800,-0.00272823678886284,-0.000888205487140518,-0.00150775253404725,-0.00427783950544068,-0.00684333926300974,-0.00687612467373002,-0.00430074888329805,-0.00153804385919643,-0.00135619533958771,-0.00421422719762474,-0.00764695311776498,-0.00846006972407959,-0.00580724466931299,-0.00219134871036170,-0.00123890874960981,-0.00419666875380569,-0.00852310710355057,-0.0101359977603706,-0.00736260349594594,-0.00278672899224414,-0.000985072393420895,-0.00409635772074326,-0.00949106280881485,-0.0120439609699949,-0.00909248627484281,-0.00331123254949911,-0.000442350266661742,-0.00374995305613202,-0.0105204219915174,-0.0143091656986992,-0.0111468624554879,-0.00377014576885177,0.000570284349154347,-0.00293454841280232,-0.0115525254185011,-0.0170978209291922,-0.0137437647742755,-0.00417136565242170,0.00233797534660630,-0.00129654267816600,-0.0125169122993329,-0.0207379205547141,-0.0172980003280536,-0.00451632738357270,0.00544209474030187,0.00186886729904535,-0.0133447313597268,-0.0260697617732556,-0.0228444427733559,-0.00479694624403622,0.0114260438680806,0.00846170944285514,-0.0139780529312683,-0.0358964923345268,-0.0339669953403191,-0.00499810249861452,0.0264298832225855,0.0267666026759814,-0.0143747151379005,-0.0667787947789595,-0.0759992741088555,-0.00510376960621198,0.130200216285966,0.263418579541359,0.318823652378022,0.263418579541359,0.130200216285966,-0.00510376960621198,-0.0759992741088555,-0.0667787947789595,-0.0143747151379005,0.0267666026759814,0.0264298832225855,-0.00499810249861452,-0.0339669953403191,-0.0358964923345268,-0.0139780529312683,0.00846170944285514,0.0114260438680806,-0.00479694624403622,-0.0228444427733559,-0.0260697617732556,-0.0133447313597268,0.00186886729904535,0.00544209474030187,-0.00451632738357270,-0.0172980003280536,-0.0207379205547141,-0.0125169122993329,-0.00129654267816600,0.00233797534660630,-0.00417136565242170,-0.0137437647742755,-0.0170978209291922,-0.0115525254185011,-0.00293454841280232,0.000570284349154347,-0.00377014576885177,-0.0111468624554879,-0.0143091656986992,-0.0105204219915174,-0.00374995305613202,-0.000442350266661742,-0.00331123254949911,-0.00909248627484281,-0.0120439609699949,-0.00949106280881485,-0.00409635772074326,-0.000985072393420895,-0.00278672899224414,-0.00736260349594594,-0.0101359977603706,-0.00852310710355057,-0.00419666875380569,-0.00123890874960981,-0.00219134871036170,-0.00580724466931299,-0.00846006972407959,-0.00764695311776498,-0.00421422719762474,-0.00135619533958771,-0.00153804385919643,-0.00430074888329805,-0.00687612467373002,-0.00684333926300974,-0.00427783950544068,-0.00150775253404725,-0.000888205487140518,-0.00272823678886284,-0.00517769037381800,-0.00599480913680623,-0.00448978288166562,-0.00196731602169841,-0.000458439212884342,-0.000999016197721182,-0.00292541015225790,-0.00461049309823788,-0.00482644914994822,-0.00354614862967617,-0.00189352391427887,-8.77803102407428e-05];

L = 608; % Filter length. Choose as small as you can. 
%If filter is linear phase, L/2 is the group delay.
k = 2;  % Downsampling rate

% Frequencies in Hz
fs = 1024; % Sampling f
fl = 1.5; % Low cutoff f
fh = 38;  % High cutoff f
% Try to get zeros at 50, 60 and 64 Hz (Notch effect). Suprassing 60Hz is
% more important than others.
% Magnitude of frequency response should be still around 1 between 30-35 Hz
% range.

maxk = floor(fs/2/fh)

if fs < 2*k*fh
    error(['Aliasing after downsampling: ', sprintf('Sampling f fs = %d < %d = (2*k*fh) Critical omega after downsampling', fs, 2*k*fh)])
end

% Find discrete omega (w) values from given parameters w={0...pi}
wl = 2*pi*fl/fs
wh = 2*pi*fh/fs
z50hzNormF = 2*1*50/fs
z60hzNormF = 2*1*60/fs %60Hz location at normalized frequency x scale for freqz
z64hzNormF = 2*1*64/fs



d = designfilt('bandpassfir', ...       % Response type
       'FilterOrder',608, ...            % Filter order
       'StopbandFrequency1',1e-99, ...    % Frequency constraints
       'PassbandFrequency1',2.6, ...
       'PassbandFrequency2',44, ...
       'StopbandFrequency2',48, ...
       'DesignMethod','equiripple', ...         % Design method
       'StopbandWeight1',1, ...         % Design method options
       'PassbandWeight', 55, ...
       'StopbandWeight2',1000, ...
       'SampleRate', 1024);               % Sample rate


   
% fvtool(pFilt)
% fvtool(d.Coefficients)

delt = -sum(d.Coefficients)/L;
noDCFilt = d.Coefficients + delt;
sm = sum(noDCFilt);

for z = 1:1000
    delt = -sum(noDCFilt)/L;
    noDCFilt = noDCFilt + delt;
    sm = sum(noDCFilt)
end


fvtool(noDCFilt);


% x = cos(2*pi*60*[0:1/(512):3-1/256]);
% figure
% y = filter(d.Coefficients,1,x);
% plot(y(77:end))
% hold
% plot(x)



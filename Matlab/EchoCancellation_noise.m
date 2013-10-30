%% ECHO Cancellation Project 
clear all
close all;
% Parameter
td = 200E-3;       % Delay Time in [s]
fs = 44100/6;      % Sampling frequency
a = 0.4;           % Gain of the Echo Signal
tk = 1/100;        % Lokale Korrelation am Anfang
u = 0.0008;          % konvergenzgeschwindigkeit

% u maximal: 0 < u < 2/((p+1)*sigma^2_x) wobei p = l�nge des filters und
% sigma = varianz
% --> u = 1/((20+1)*std(x)^2)

w_global = true;

% Load Signal
[sound, fswav, nbit]= wavread('Lorem_ipsum_3500.wav');
x = sound(round(1:fswav/fs:end));  % Undersampling
clearvars sound;

%soundsc(x, fs);   % play sound

x=randn(size(x));

% Create Echo
nshift = floor(td*fs);

g = zeros(size(x));
g(1) = 1;
g(8) = a;
y=filter(g,1,x);

%soundsc(y, fs);   % play sound + echo

%% Signal Processing
NFIR = 20;
%deltak = floor(tk*fs);
deltak = 1;
if w_global == true
    w = zeros(NFIR - deltak, length(x) - NFIR+2);
else
    w = zeros(NFIR - deltak, 1);
end

err = zeros(size(x));

for k = NFIR:length(x);
    if w_global == true
        err(k)=y(k)-w(:,k-NFIR+1)'*x(k-deltak:-1:k-NFIR+1);
        w(:,k-NFIR+2) = w(:,k-NFIR+1) + u*x(k-deltak:-1:k-NFIR+1)*(err(k));
    else
        err(k)=y(k)-w'*x(k-deltak:-1:k-NFIR+1);
        w = w + u*x(k-deltak:-1:k-NFIR+1)*(err(k));
    end
end

% figure
% plot(err(1:500), 'linewidth', 2);
% title('Error over time');
% xlabel('Time [Samples]');

if w_global == true
    figure
    surf(w(:,1:100:end));
    set(gca, 'YDir', 'reverse')
    title('Convergence of filter');
    xlabel('Time [Samples]');
    ylabel('Filter coefficients');
    figure;
    plot(g(1:NFIR), '--', 'linewidth', 2);
    hold all;
    plot([zeros(deltak, 1); w(:,end)], 'linewidth', 2);
    legend('Original echo', 'Reproduced echo');
    title('Final filter coefficients');
    xlabel('Filter coefficients');
else
    figure;
    plot([zeros(deltak,1); w]);
    hold all;
    plot(g(1:length(w)));
end

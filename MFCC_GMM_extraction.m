% Automated VAD, MFCC feature extraction and GMM fit from audio files
%% Constants
fs = 44100;
nCoef = 10;
E_th = 0.01;
k = 3;

%% Extraction
files = dir('samples\*.m4a')';
nSp = length(files);
names = {files.name};
% n: mean + n*(n+1)/2: covariance matrix unique elements
features = zeros(nCoef,0);
Y = zeros(1,0);

for i = 1:nSp
    file = files(i);
    [aIn,~] = audioread([file.folder '\' file.name]);
    if size(aIn,2) ~= 1 % Not mono audio
        aIn = mean(aIn,2); % Then get intrachannel average
    end
    tmp = getMFCC(aIn,fs,nCoef,E_th);
    features = [features, tmp];
    Y = [Y, i*ones(1,size(tmp,2))];
end

%% Classwise GMM fit & global model construction
mus = zeros(nSp*k,nCoef);
Sigmas = zeros(nCoef,nCoef,nSp*k);
p = zeros(nSp*k,1);

for i = 1:nSp
    feature = features(:, Y == i)';
    gm = fitgmdist(feature,k, ...
        'RegularizationValue',1e-12, ...
        'Options',statset('MaxIter',1500));
    mus((i-1)*k+1:i*k, :) = gm.mu;
    Sigmas(:,:,(i-1)*k+1:i*k) = gm.Sigma;
    p((i-1)*k+1:i*k) = gm.ComponentProportion;
end
p = p/nSp;

gm = gmdistribution(mus,Sigmas,p);

%% Save features
save('MFCC_GMM_features', 'fs', 'E_th', 'nCoef', 'k', 'names', 'gm');

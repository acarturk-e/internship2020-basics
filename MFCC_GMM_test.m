% Tests MFCC feature mean and covariance matrix extraction online.
%% Setup
load('MFCC_GMM_features.mat');
n_30ms = 0.03 * fs;
nSp = length(names);
bufferSize = 10; % A buffer of 30 ms * 30 == 0.9 s

deviceReader = audioDeviceReader(fs, n_30ms);
setup(deviceReader);

%%
piHat = ones(nSp, 1);

figure(1)
plt = bar(piHat);
set(gca, 'xtick', 1:length(names), 'xticklabel', names);

ylim([0 1])
xlabel('Speaker')
ylabel('Probability')

plt.YDataSource = 'piHat';

%%
y_buff = zeros(4*n_30ms,1);
y_buff = circshift(y_buff,-n_30ms);
y_buff(end-n_30ms+1:end) = deviceReader();

piHats = zeros(nSp, bufferSize);
while true
    y_buff = circshift(y_buff,-n_30ms);
    y_buff(end-n_30ms+1:end) = deviceReader();
    tmp = [];
    try
        coef = getMFCC(y_buff,fs,nCoef,3*E_th);
        [~,~,probs] = cluster(gm, coef');
        probs = sum(reshape(probs,[size(probs,1),k,nSp]),2);
        probs = mean(probs,1);
        probs = probs(:);

        piHats = circshift(piHats,-1,2);
        piHats(:,end) = probs;
        piHat = mean(piHats,2);
    catch ME
        if strcmp(ME.identifier, 'getMFCC:notVoiced')
            disp(ME.identifier)
        else
            rethrow(ME);
        end
    end

    refreshdata
    drawnow
end

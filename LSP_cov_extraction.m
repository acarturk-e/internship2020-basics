% Calculates linear predictor model parameters' covariance matrix.

%% Get voice input
disp('Starting feature extraction')

p = 10;
fs = 44100;
n_10ms = fs*0.010;
E_threshold = 0.0100;

files = dir('samples\*.m4a')';

features = struct('name',{},'covm',{},'mean',{});

for file = files

    [~,name,~] = fileparts(file.name);
    disp(['  Now processing: ' name])
    [y,~] = audioread([file.folder '\' file.name]);
    is_voiced = zeros(size(y));

    m_v   = zeros([p,1]);
    cov_m = zeros([p,p]);
    N     = 1;

    N_cnt = floor(length(y)/n_10ms) - 10;
    n_cnt = 0;
    while n_cnt < N_cnt

        x = y(n_10ms*n_cnt+1: n_10ms*(n_cnt+11));
        E = sum(x.^2)/(n_10ms*3);

        if E > E_threshold

            is_voiced(n_10ms*n_cnt+1: n_10ms*(n_cnt+11)) = 1;

            a = lpc(x,p);
            lsp = poly2lsf(a) - m_v;

            cov_m = cov_m.*(1 - 1/N) + lsp*lsp'./(N+1);
            m_v = m_v + lsp./(N+1);

        end

        n_cnt = n_cnt + 1;

    end
%{
    figure; plot(y); hold on; plot(is_voiced); hold off;
%}
    feature.name = name;
    feature.covm = cov_m;
    feature.mean = m_v;
    features(end+1) = feature;

    i = i + 1;

end

disp('Feature extraction complete')

%%
save('LSP_features', 'features', 'p', 'fs', 'n_10ms', 'E_threshold');
clear

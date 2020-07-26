% Real time recognition test using LSP cov matrix similarity

%%
load('LSP_cov.mat');
nSp = length(names);
N_max = 100;

bs = 11;
deviceReader = audioDeviceReader(fs, n_10ms);
setup(deviceReader);

piHat = zeros(nSp, 1);

figure(1)
plt = bar(piHat);
set(gca, 'xtick', 1:length(names), 'xticklabel', names);

ylim([0 1])
xlabel('Speaker')
ylabel('Probability (Monotonously transformed)')

plt.YDataSource = 'piHat';

%%
y_buff = zeros(bs*n_10ms,1);
for i = 1:bs-1
    y_buff = [y_buff(n_10ms+1:bs*n_10ms,1); deviceReader()];
end

m_v   = zeros([p,1]);
cov_m = zeros([p,p]);
N     = 1;

while 1

    y_buff = [y_buff(n_10ms+1:bs*n_10ms,1); deviceReader()];
    
    E = sum(y_buff.^2)/(bs*n_10ms);

    if E >= E_threshold

        a = lpc(y_buff,p);
        lsp = poly2lsf(a) - m_v;

        cov_m = cov_m.*(1 - 1/N) + lsp*lsp'./(N+1);
        m_v = m_v + lsp./(N+1);

        for i = 1:nSp
            piHat(i) = 1./(1 + norm(COV_M(:,:,i) - cov_m, 'fro'));
        end

        if N <= N_max
            N = N + 1;
        end

        refreshdata
        drawnow

    end

end

%%
release(deviceReader)

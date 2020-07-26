%% curr

p     = 12;
x     = ones([p, 1]);
m_v   = zeros([p, 1]);
cov_m = zeros(p);
N     = 1;
N_max = 1000;

while N < N_max

    x = rand([p, 1]);

    cov_m = cov_m.*(1 - 1/N) + (x-m_v)*(x-m_v)'./(N+1);
    m_v = m_v + (x - m_v)./(N+1);
    N = N + 1;

end

figure(1); bar(m_v); title("Mean vector");
figure(2); mesh(cov_m); title("Covariance matrix");

% a nice similarity measure: 1/(1+norm(cov_m, 'fro'))

%% prev
fs = 44100;
n_10ms = fs*0.010;
N = 5000;
N_cnt = floor(N/n_10ms) - 2;
y = ones([1,N]);
X = [];
Y = [];
p = 12;

    n_cnt = 0;
    while n_cnt < N_cnt

        x = y(n_10ms*n_cnt+1: n_10ms*(n_cnt+3));
        E = sum(x.^2)/(n_10ms*3);

        if 1

            [a,g] = lpc(x,p);
            lsp = poly2lsf(a)';
            features = [a(2:end),lsp];
            X = [X; features];
            Y = [Y; iterCnt];

        end

        n_cnt = n_cnt + 1;

    end

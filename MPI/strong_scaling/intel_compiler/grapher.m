set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'DefaultLegendInterpreter', 'latex')

nnode = 2;

num = cell(3, nnode);

num(:,1) = {'8053455', '8053456', '8053457'};
num(:,2) = {'8053458', '8053459', '8053460'};

name = cell(3, nnode);

for i = 1:nnode
    name{1,i} = ['slurm-', num{1,i}, '.out'];
    name{2,i} = ['slurm-', num{2,i}, '.out'];
    name{3,i} = ['slurm-', num{3,i}, '.out'];
end




n = zeros(0,1);
t = zeros(0,1);

for i = 1 : 2
    
    data_1 = load(name{1,i});
    data_2 = load(name{2,i});
    data_3 = load(name{3,i});
    
    n_ = data_1(:, 1);
    n = cat(1,n, n_);
    
    t_ = (data_1(:,5) + data_2(:,5) + data_3(:,5))./3;
    
    if(i == 1)
        t0 = t_(1);
    end
    
    t_ = t0./t_;
    
    t = cat(1,t, t_);
    
    if(i == 1)
        n_fit = n_;
        p1 = polyfit(log(n_), log(t_), 1);
        c11 = p1(1);
        c12 = p1(2);
        z = polyval(p1,log(n_));
    end
end

figure(1)

loglog(n, t, '+');

hold on

loglog(n_fit,exp(z),'r');

hold off

axis([0.7 100 0.8 40])
grid on;
xlabel('\# processes $n$');
ylabel('Speed-up')

legend('Data', ['Fit : $\log(S) =$ ', num2str(c11, 2), ' $ \log(n) + $', num2str(c12, 2)], 'location', 'best')

set(gcf,'PaperUnits', 'centimeters', 'PaperPosition', [0 0 15 7.5]);
print('strong_intel', '-depsc','-r0');



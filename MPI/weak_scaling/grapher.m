set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'DefaultLegendInterpreter', 'latex')

nnode = 2;

num = cell(3, nnode);

num(:,1) = {'7895389', '7895391', '7895392'};
num(:,2) = {'7895621', '7895622', '7895624'};

name = cell(3, nnode);

for i = 1:nnode
    name{1,i} = ['slurm-', num{1,i}, '.out'];
    name{2,i} = ['slurm-', num{2,i}, '.out'];
    name{3,i} = ['slurm-', num{3,i}, '.out'];
end




n = zeros(0,1);
E = zeros(0,1);

for i = 1 : nnode
    
    data_1 = load(name{1,i});
    data_2 = load(name{2,i});
    data_3 = load(name{3,i});
    
    n_ = data_1(:, 1);
    n = cat(1,n, n_);
    
    step = data_1(:, 3);
    t_ = (data_1(:,5) + data_2(:,5) + data_3(:,5))./3;
    
    t_ = t_./step;   %time/step
    
    if(i == 1)
        t0 = t_(1);
    end
    
%     t_ = n_*t0./t_;
    t_ = t0./t_;
    
    E = cat(1,E, t_);
    
    if(i==1)
        n_fit = n_;
        p1 = polyfit(n_, E, 1);
        c11 = p1(1);
        c12 = p1(2);
        z = polyval(p1,n_);
    end
end


figure(1)

plot(n, E, '+');
hold on

yline(1,'r');
hold off

axis([0 60 0.9 1.02])
grid on;
xlabel('\# processes $n$');
ylabel('Efficiency')

legend('Data', 'Ideal Efficiency', 'location', 'southwest')

set(gcf,'PaperUnits', 'centimeters', 'PaperPosition', [0 0 15 7.5]);
print('weak', '-depsc','-r0');



set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'DefaultLegendInterpreter', 'latex')

nnode = 4;

num = cell(3, nnode);

base = 'slurm-4796';

num(:,1) = {'25', '26', '27'};
num(:,2) = {'28', '29', '30'};
num(:,3) = {'33', '34', '35'};
num(:,4) = {'36', '37', '38'};

name = cell(3, nnode);

for i = 1:nnode
    name{1,i} = [base, num{1,i}, '.out'];
    name{2,i} = [base, num{2,i}, '.out'];
    name{3,i} = [base, num{3,i}, '.out'];
end


title_ = {'1D', '2D', 'Difference between 2D versions', '1D and 2D'};
leg = {'One thread per row','One thread per column', 'One thread per entry', sprintf('\nOne thread per entry\nwith shared memory\n')};

for i = 1 : 4
    
    data_1 = load(name{1,i});
    data_2 = load(name{2,i});
    data_3 = load(name{3,i});
    
    if(i<3)
        nb_threads = data_1(:, 1);
    else
        nb_threads = (data_1(:, 1)).^2;
    end
    
    N = data_1(:, 2);
    
    steps = data_1(:, 3);
    
    t = (data_1(:,4) + data_2(:,4) + data_3(:,4))./3;
    t = t./steps;
    
    if(i>2)         % Only for 2D
        if(i==3)
            diff = t;
        end
        if(i==4)
            diff = abs(diff-t);
            diff./steps;
        end
        figure(3)

        plot(log2(nb_threads), diff)
%         semilogy(log2(nb_threads), diff);

        grid on;

        xlabel('Number of threads per block $n$');
        ylabel('Time difference [s]');
    end
    
    
    floor((i-1)/2 + 1);
    figure(floor((i-1)/2 + 1));
    
%     plot(log2(nb_threads), t)
%     loglog(nb_threads, t)
%     semilogx(nb_threads, t);
    semilogy(log2(nb_threads), t);
    
    hold on;
    
    grid on;

    xlabel('Number of threads per block $n$');
    ylabel('Time/step [s]');
    
    figure(4)
    semilogy(log2(nb_threads), t);
    
    hold on;
    
    grid on;

    xlabel('Number of threads per block $n$');
    ylabel('Time/step [s]');
    
    
end

for i = 1:4
    figure(i)
    xticks = 0:10;
    set(gca, 'XTick', xticks);
    set(gca, 'XTickLabel', 2.^xticks)
end


figure(1)
title(title_{1});
legend(leg{1}, leg{2}, 'location', 'north')
axis([0 10 1.0e-03 2.5e-02]);

set(gcf,'PaperUnits', 'centimeters', 'PaperPosition', [0 0 15 7.5]);
print('1D', '-depsc','-r0');

figure(2)
title(title_{2});
legend(leg{3}, leg{4}, 'location', 'north')
axis([0 10 3.0e-04 3.0e-02]);

set(gcf,'PaperUnits', 'centimeters', 'PaperPosition', [0 0 15 7.5]);
print('2D', '-depsc','-r0');

figure(3)
title(title_{3});
legend('Time difference', 'location', 'north')

set(gcf,'PaperUnits', 'centimeters', 'PaperPosition', [0 0 15 7.5]);
print('difference', '-depsc','-r0');


figure(4)
title(title_{4});
legend(leg{1}, leg{2}, leg{3}, leg{4}, 'location', 'north')
axis([0 10 3.0e-04 3.0e-02]);

set(gcf,'PaperUnits', 'centimeters', 'PaperPosition', [0 0 15 7.5]);
print('All', '-depsc','-r0');

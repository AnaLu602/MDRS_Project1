%% exercicio c

N = 50; %number of simulations
per1= zeros(1,N); %vector with N simulation values
per2= zeros(1,N); %vector with N simulation values
per3 = zeros(1,N);
per4 = zeros(1,N);
lambda = 1800;
C = [10, 20, 30, 40];
f = 1000000;
P = 10000;

dataAvgPacketDelay = [];
dataAvgPacketDelayConfidence = [];

for index = 1:length(C)
    for it= 1:N
    [per1(it),per2(it),per3(it),per4(it)]= simulator1(lambda,C(index),f,P);
    end
    
    alfa= 0.1; %90% confidence interval%
    fprintf('C = %.2e\n',C(index))

    media = mean(per2);
    term = norminv(1-alfa/2)*sqrt(var(per2)/N);
    fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)

    dataAvgPacketDelay = [dataAvgPacketDelay, media];
    dataAvgPacketDelayConfidence = [dataAvgPacketDelayConfidence, term];    
    
end

Cname = {'10','20','30','40'}; 

figure(1)
bar(dataAvgPacketDelay)
set(gca,'xtickLabel',Cname);

xlabel('Capacity (Mbps)')
title('Av. Packet Delay (ms)')
ylim([0,6]);

hold on

er = errorbar(1:4,dataAvgPacketDelay,dataAvgPacketDelayConfidence,dataAvgPacketDelayConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off




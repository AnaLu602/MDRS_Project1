%% exercicio b

N = 50; %number of simulations
per1= zeros(1,N); %vector with N simulation values
per2= zeros(1,N); %vector with N simulation values
per3 = zeros(1,N);
per4 = zeros(1,N);
lambda = 1800;
C = 10;
f = [100000, 20000, 10000, 2000];
P = 10000;

dataPacketLoss = [];
dataAvgPacketDelay = [];
dataPacketLossConfidence = [];
dataAvgPacketDelayConfidence = [];

for index = 1:length(f)
    for it= 1:N
    [per1(it),per2(it),per3(it),per4(it)]= simulator1(lambda,C,f(index),P);
    end
    
    alfa= 0.1; %90% confidence interval%
    fprintf('F = %.2e\n',f(index))
    media = mean(per1);
    term = norminv(1-alfa/2)*sqrt(var(per1)/N);
    fprintf('PacketLoss (percentage) = %.2e +- %.2e\n',media,term)

    dataPacketLoss = [dataPacketLoss, media];
    dataPacketLossConfidence = [dataPacketLossConfidence, term];

    media = mean(per2);
    term = norminv(1-alfa/2)*sqrt(var(per2)/N);
    fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)

    dataAvgPacketDelay = [dataAvgPacketDelay, media];
    dataAvgPacketDelayConfidence = [dataAvgPacketDelayConfidence, term];    
    
end

fname = {'100000','20000','10000','2000'}; 

figure(1)
bar(dataPacketLoss)
set(gca,'xtickLabel',fname);

xlabel('B (Bytes)')
title('Packet Loss %')

hold on

er = errorbar(1:4,dataPacketLoss,dataPacketLossConfidence,dataPacketLossConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(2)
bar(dataAvgPacketDelay)
set(gca,'xtickLabel',fname);

xlabel('B (Bytes)')
title('Av. Packet Delay (ms)')

hold on

er = errorbar(1:4,dataAvgPacketDelay,dataAvgPacketDelayConfidence,dataAvgPacketDelayConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off




%% a

N = 50; %number of simulations
PL = zeros(1,N); %vector with N simulation values
APD = zeros(1,N); %vector with N simulation values
MPD = zeros(1,N);
TT = zeros(1,N);

lambda = [400, 800, 1200, 1600, 2000];
C = 10;
f = 1000000;
P = 10000;

alfa= 0.1; %90% confidence interval%

dataAvgPacketDelay = zeros(length(lambda),1);
dataAvgPacketDelayConfidence = zeros(length(lambda),1);

for i = 1:length(lambda)
    for n = 1:N
        [PL(n), APD(n), MPD(n), TT(n)] = Simulator1(lambda(i),C,f,P);
    end
    
    media = mean(PL);
    term = norminv(1-alfa/2)*sqrt(var(PL)/N);
    fprintf('PacketLoss (%%) = %.2e +- %.2e\n',media,term)

    media = mean(APD);
    dataAvgPacketDelay(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APD)/N);
    dataAvgPacketDelayConfidence(i) = term;
    fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
    
    media = mean(MPD);
    term = norminv(1-alfa/2)*sqrt(var(MPD)/N);
    fprintf('Max. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
    
    media = mean(TT);
    term = norminv(1-alfa/2)*sqrt(var(TT)/N);
    fprintf('Throughput (Mbps) = %.2e +- %.2e\n\n',media,term)

end

figure(1)
bar(lambda,dataAvgPacketDelay)

xlabel('Packet rate (pps)')
ylabel('Average packet delay (ms)')
ylim([0,35])
hold on
er = errorbar(lambda,dataAvgPacketDelay,dataAvgPacketDelayConfidence,dataAvgPacketDelayConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off


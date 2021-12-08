%% a

N = 50; %number of simulations
PL = zeros(1,N); %vector with N simulation values
APD = zeros(1,N); %vector with N simulation values
APD64 = zeros(1,N);
APD110 = zeros(1,N);
APD1518 = zeros(1,N);
MPD = zeros(1,N);
TT = zeros(1,N);

lambda = 1800;
C = [10, 20, 30, 40];
f = 1000000;
P = 10000;

alfa= 0.1; %90% confidence interval%

dataAvgPacketDelay = zeros(length(C),1);
dataAvgPacketDelayConfidence = zeros(length(C),1);

dataAvgPacketDelay64 = zeros(length(C),1);
dataAvgPacketDelayConfidence64 = zeros(length(C),1);

dataAvgPacketDelay110 = zeros(length(C),1);
dataAvgPacketDelayConfidence110 = zeros(length(C),1);

dataAvgPacketDelay1518 = zeros(length(C),1);
dataAvgPacketDelayConfidence1518 = zeros(length(C),1);

for i = 1:length(C)
    for n = 1:N
        [PL(n), APD(n), APD64(n), APD110(n), APD1518(n), MPD(n), TT(n)] = simulator1e(lambda,C(i),f,P);
    end
    
    fprintf('--------Capacity %d--------\n', C(i));
    media = mean(PL);
    term = norminv(1-alfa/2)*sqrt(var(PL)/N);
    fprintf('PacketLoss (%%) = %.2e +- %.2e\n',media,term)

    media = mean(APD);
    dataAvgPacketDelay(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APD)/N);
    dataAvgPacketDelayConfidence(i) = term;
    fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)

    media = mean(APD64);
    dataAvgPacketDelay64(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APD64)/N);
    dataAvgPacketDelayConfidence64(i) = term;
    fprintf('Av. 64 Bytes Packet Delay (ms) = %.2e +- %.2e\n',media,term)

    media = mean(APD110);
    dataAvgPacketDelay110(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APD110)/N);
    dataAvgPacketDelayConfidence110(i) = term;
    fprintf('Av. 110 Bytes Packet Delay (ms) = %.2e +- %.2e\n',media,term)

    media = mean(APD1518);
    dataAvgPacketDelay1518(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APD1518)/N);
    dataAvgPacketDelayConfidence1518(i) = term;
    fprintf('Av. 1518 Bytes Packet Delay (ms) = %.2e +- %.2e\n',media,term)
    
    media = mean(MPD);
    term = norminv(1-alfa/2)*sqrt(var(MPD)/N);
    fprintf('Max. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
    
    media = mean(TT);
    term = norminv(1-alfa/2)*sqrt(var(TT)/N);
    fprintf('Throughput (Mbps) = %.2e +- %.2e\n\n',media,term)

end

figure(1)
bar(C,dataAvgPacketDelay)

xlabel('Link capacity (Mbps)')
title('Average packet delay (ms)')

hold on
er = errorbar(C,dataAvgPacketDelay,dataAvgPacketDelayConfidence,dataAvgPacketDelayConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(2)
bar(C,dataAvgPacketDelay64)

xlabel('Link capacity (Mbps)')
title('Average 64 Bytes packet delay (ms)')

hold on
er = errorbar(C,dataAvgPacketDelay64,dataAvgPacketDelayConfidence64,dataAvgPacketDelayConfidence64);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(3)
bar(C,dataAvgPacketDelay110)

xlabel('Link capacity (Mbps)')
title('Average 110 Bytes packet delay (ms)')

hold on
er = errorbar(C,dataAvgPacketDelay110,dataAvgPacketDelayConfidence110,dataAvgPacketDelayConfidence110);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(4)
bar(C,dataAvgPacketDelay1518)

xlabel('Link capacity (Mbps)')
title('Average 1518 Bytes packet delay (ms)')

hold on
er = errorbar(C,dataAvgPacketDelay1518,dataAvgPacketDelayConfidence1518,dataAvgPacketDelayConfidence1518);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off


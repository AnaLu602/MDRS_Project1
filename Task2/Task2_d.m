%% Task 2.d.

N = 50; %number of simulations
PLdata = zeros(1,N); %vector with N simulation values
PLvoIP = zeros(1,N);
APDdata = zeros(1,N); 
APDvoIP = zeros(1,N); 
MPDdata = zeros(1,N);
MPDvoIP = zeros(1,N);
TT = zeros(1,N);
    
lambda = 1500; %pps
C = 10;        %Mbps
f = 10000;     %Bytes
P = 10000;     %packets (stop criterion)

nVoIP = [10,20,30,40];   %number of VoIP flows

alfa= 0.1; %90% confidence interval%

dataPacketLoss = zeros(length(lambda),1);
dataPacketLossConfidence = zeros(length(lambda),1);

voIPPacketLoss = zeros(length(lambda),1);
voIPPacketLossConfidence = zeros(length(lambda),1);

dataAvgPacketDelay = zeros(length(lambda),1);
dataAvgPacketDelayConfidence = zeros(length(lambda),1);

voIPAvgPacketDelay = zeros(length(lambda),1);
voIPAvgPacketDelayConfidence = zeros(length(lambda),1);

for i = 1:length(nVoIP)
    for n = 1:N
         [PLdata(n), PLvoIP(n), APDdata(n), APDvoIP(n), MPDdata(n), MPDvoIP(n), TT(n)] = Simulator3(lambda,C,f,P,nVoIP(i));
    end
    
    media = mean(PLdata);
    dataPacketLoss(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(PLdata)/N);
    dataPacketLossConfidence(i) = term;
    fprintf('PacketLoss data packets (%%) = %.2e +- %.2e\n',media,term)
    
    media = mean(PLvoIP);
    voIPPacketLoss(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(PLvoIP)/N);
    voIPPacketLossConfidence(i) = term;
    fprintf('PacketLoss voIP packets (%%) = %.2e +- %.2e\n',media,term)

    media = mean(APDdata);
    dataAvgPacketDelay(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APDdata)/N);
    dataAvgPacketDelayConfidence(i) = term;
    fprintf('Av. Packet Delay data packets (ms) = %.2e +- %.2e\n',media,term)

    media = mean(APDvoIP);
    voIPAvgPacketDelay(i) = media;
    term = norminv(1-alfa/2)*sqrt(var(APDvoIP)/N);
    voIPAvgPacketDelayConfidence(i) = term;
    fprintf('Av. Packet Delay voIP packets (ms) = %.2e +- %.2e\n',media,term)

end

figure(1)
bar(nVoIP,dataAvgPacketDelay)

xlabel('Number of VoIP flows')
title('Average data packet delay (ms)')

hold on
er = errorbar(nVoIP,dataAvgPacketDelay,dataAvgPacketDelayConfidence,dataAvgPacketDelayConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(2)
bar(nVoIP,voIPAvgPacketDelay)

xlabel('Number of VoIP flows')
title('Average VoIP packet delay (ms)')

hold on
er = errorbar(nVoIP,voIPAvgPacketDelay,voIPAvgPacketDelayConfidence,voIPAvgPacketDelayConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(3)
bar(nVoIP,dataPacketLoss)

xlabel('Number of VoIP flows')
title('Data Packet Loss (%)')

hold on
er = errorbar(nVoIP,dataPacketLoss,dataPacketLossConfidence,dataPacketLossConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

figure(4)
bar(nVoIP,voIPPacketLoss)

xlabel('Number of VoIP flows')
title('VoIP Packet Loss (%)')

hold on
er = errorbar(nVoIP,voIPPacketLoss,voIPPacketLossConfidence,voIPPacketLossConfidence);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
hold off

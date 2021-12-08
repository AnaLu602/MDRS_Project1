%% Task 2.c.
%--------------------------------
%-------System parameters--------
%--------------------------------   
lambda = 1500;          %pps (data packets)
C = 10 * 10^6;          %bps
f = 1000000;            %Bytes
nVoIP = [10,20,30,40];  %number of VoIP flows

%--------------------------------
%----------Data packets----------
%--------------------------------

% packet sizes: 19% for 64 bytes, 23% for 110 bytes, 17% for 1518 bytes
%               equal probability for all other values (65 to 109 and 111 to 1517)
nPacketSizes = 1518-64 + 1;
otherProbability = (1 - 0.19 - 0.23 - 0.17) / (nPacketSizes - 3);

dataPacketProb(64:1518) = otherProbability;  %vector containing all packets probabilities
dataPacketProb(64) = 0.19;
dataPacketProb(110) = 0.23;
dataPacketProb(1518) = 0.17;

% Expected value of data packet transmission time
EDataPacket = 0; %seconds
% Second Moment of data packet transmission time
ESqrDataPacket = 0; %seconds

for i = 64:1518
    packetTransmitionTime = i*8/C;
    EDataPacket = EDataPacket + packetTransmitionTime * dataPacketProb(i);
    ESqrDataPacket = ESqrDataPacket + packetTransmitionTime^2 * dataPacketProb(i);
end

% mean queue delay
%Wq = lambda*ESqrDataPacket / (2 * (1 - lambda*EDataPacket));
% mean system delay
%W = Wq + EDataPacket;


%--------------------------------
%----------VoIP packets----------
%--------------------------------
%
%VoIP packet sizes: uniformly distributed between 110 and 130 Bytes
%VoIP time between arrivals: uniformly distribued between 16 and 24 ms
%
%Uniform distribution
%a - minimum value
%b - maximum value
%E(X) = 1/2(b+a)
%E(X^2) = (b^3 - a^3) / (3*b - 3*a)

minTransmitionTime = 110*8/C;    %seconds
maxTransmitionTime = 130*8/C;    %seconds

% Expected value of VoIP packet transmission time
EVoipPacket = 1/2*(maxTransmitionTime+minTransmitionTime); %seconds
% Second moment of VoIP packet transmission time
ESqrVoipPacket = (maxTransmitionTime^3 - minTransmitionTime^3) / (3*maxTransmitionTime - 3*minTransmitionTime); %seconds

minArrivalTime = 16 / 1000;    %seconds
maxArrivalTime = 24 / 1000;    %seconds

% Expected value of VoIP packet transmission time (mean)
EVoipArrivalTime = 1/2*(maxArrivalTime+minArrivalTime); %seconds
% VoIP arrivals rate
VoipRate = 1 / EVoipArrivalTime; %pps

%--------------------------------
%-----M/G/1 with priorities------
%--------------------------------
% N VoIP flows (nVoip * voipRate pps), 1 data flow (lambda pps / 1500 pps)
% VoIP priority > Data priority
% All VoIP flows have same priority

% VoIP flow rate vector counting with all VoIP flows
AllVoipRate = VoipRate * nVoIP;  %pps

roVoIP = AllVoipRate * EVoipPacket;
roData = lambda * EDataPacket;

% mean queue delay VoIP vector
WqVoIP = (AllVoipRate .* ESqrVoipPacket + lambda * ESqrDataPacket) ./ (2 .* (1 - roVoIP) ); %ms
% mean system delay VoIP vector
WVoip = (WqVoIP + EVoipPacket) * 1000; %seconds

% mean system delay Data vector
WqData = (AllVoipRate .* ESqrVoipPacket + lambda * ESqrDataPacket) ./ (2 .* (1 - roVoIP) .* (1 - roVoIP - roData) ); %ms
% mean system delay VoIP vector
WData = (WqData + EDataPacket) * 1000; %seconds

%--------------------------------
%----------Bar Charts------------
%--------------------------------
figure(1)
bar(nVoIP,WData)

xlabel('Number of VoIP flows')
title('Average data packet delay (ms)')

figure(2)
bar(nVoIP,WVoip)

xlabel('Number of VoIP flows')
title('Average VoIP packet delay (ms)')




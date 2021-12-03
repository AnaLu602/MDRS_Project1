function [PL , APD , APD64, APD110, APD1518, MPD , TT] = Simulator1(lambda,C,f,P)
% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
% OUTPUT PARAMETERS:
%  PL   - packet loss (%)
%  APD  - average packet delay (milliseconds)
%  MPD  - maximum packet delay (milliseconds)
%  APD64 - average packet delay of packet of size 64
%  APD110 - average packet delay of packet of size 110
%  APD1518 - average packet delay of packet of size 1518
%  TT   - transmitted throughput (Mbps)

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

%State variables:
STATE = 0;          % 0 - connection free; 1 - connection bysy
QUEUEOCCUPATION= 0; % Occupation of the queue (in Bytes)
QUEUE= [];          % Size and arriving time instant of each packet in the queue

%Statistical Counters:
TOTALPACKETS= 0;            % No. of packets arrived to the system
LOSTPACKETS= 0;             % No. of packets dropped due to buffer overflow
TRANSMITTEDPACKETS= 0;      % No. of transmitted packets
TRANSMITTEDPACKETS64= 0;    % Sum of the Bytes of transmitted packets
TRANSMITTEDPACKETS110= 0;   % Sum of the Bytes of transmitted packets
TRANSMITTEDPACKETS1518= 0;  % Sum of the Bytes of transmitted packets
TRANSMITTEDBYTES= 0;        % Sum of the Bytes of transmitted packets
DELAYS= 0;                  % Sum of the delays of transmitted packets
DELAYS64= 0;                % Sum of the delays of transmitted packets 64
DELAYS110= 0;               % Sum of the delays of transmitted packets 110
DELAYS1518= 0;              % Sum of the delays of transmitted packets 1518

MAXDELAY= 0;           % Maximum delay among all transmitted packets

% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first ARRIVAL:
tmp= Clock + exprnd(1/lambda);
EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp];

%Similation loop:
while TRANSMITTEDPACKETS<P               % Stopping criterium
    EventList= sortrows(EventList,2);    % Order EventList by time
    Event= EventList(1,1);               % Get first event and 
    Clock= EventList(1,2);               %   and
    PacketSize= EventList(1,3);          %   associated
    ArrivalInstant= EventList(1,4);      %   parameters.
    EventList(1,:)= [];                  % Eliminate first event
    switch Event
        case ARRIVAL                     % If first event is an ARRIVAL
            TOTALPACKETS= TOTALPACKETS+1;
            tmp= Clock + exprnd(1/lambda);
            EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp];
            if STATE==0
                STATE= 1;
                EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock];
            else
                if QUEUEOCCUPATION + PacketSize <= f
                    QUEUE= [QUEUE;PacketSize , Clock];
                    QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                else
                    LOSTPACKETS= LOSTPACKETS + 1;
                end
            end
        case DEPARTURE                     % If first event is a DEPARTURE
            TRANSMITTEDBYTES= TRANSMITTEDBYTES + PacketSize;
            DELAYS= DELAYS + (Clock - ArrivalInstant);
            
            if Clock - ArrivalInstant > MAXDELAY
                MAXDELAY= Clock - ArrivalInstant;
            end
            
            TRANSMITTEDPACKETS= TRANSMITTEDPACKETS + 1;
            
            if PacketSize==64
                TRANSMITTEDPACKETS64 = TRANSMITTEDPACKETS64 + 1;
                DELAYS64= DELAYS64 + (Clock - ArrivalInstant);
            elseif PacketSize==110
                TRANSMITTEDPACKETS110 = TRANSMITTEDPACKETS110 + 1;
                DELAYS110= DELAYS110 + (Clock - ArrivalInstant);
            elseif PacketSize==1518
                TRANSMITTEDPACKETS1518 = TRANSMITTEDPACKETS1518 + 1;
                DELAYS1518= DELAYS1518 + (Clock - ArrivalInstant);
            end
            if QUEUEOCCUPATION > 0
                EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2)];
                QUEUEOCCUPATION= QUEUEOCCUPATION - QUEUE(1,1);
                QUEUE(1,:)= [];
            else
                STATE= 0;
            end
    end
end

%Performance parameters determination:
PL= 100*LOSTPACKETS/TOTALPACKETS;               % in %
APD= 1000*DELAYS/TRANSMITTEDPACKETS;            % in milliseconds
APD64= 1000*DELAYS64/TRANSMITTEDPACKETS64;      % in milliseconds
APD110= 1000*DELAYS110/TRANSMITTEDPACKETS110;   % in milliseconds
APD1518= 1000*DELAYS1518/TRANSMITTEDPACKETS1518;% in milliseconds
MPD= 1000*MAXDELAY;                             % in milliseconds
TT= 10^(-6)*TRANSMITTEDBYTES*8/Clock;           % in Mbps

end

function out= GeneratePacketSize()
    aux= rand();
    aux2= [65:109 111:1517];
    if aux <= 0.19
        out= 64;
    elseif aux <= 0.19 + 0.23
        out= 110;
    elseif aux <= 0.19 + 0.23 + 0.17
        out= 1518;
    else
        out = aux2(randi(length(aux2)));
    end
end
function [PLdata , PLvoIP, APDdata, APDvoIP, MPDdata, MPDvoIP, TT] = Simulator4(lambda,C,f,P,nVoIP)
% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
%  nVoIP  - number of voIP packet flows

% OUTPUT PARAMETERS:
%  PLdata - packet loss of data packets (%)
%  PLvoIP - packet loss of VoIP packets (%)
%  APDdata - average packet delay of data packets (milliseconds)
%  APDvoIP - average packet delay of VoIP packets (milliseconds)
%  MPDdata - maximum packet delay of data packets (milliseconds)
%  MPDvoip - maximum packet delay of voip packets (milliseconds)
%  TT   - transmitted throughput (Mbps)

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

%Packet type:
VoIP = 0;
Data = 1;

%State variables:
STATE = 0;           % 0 - connection free; 1 - connection bysy
QUEUEOCCUPATION = 0; % Occupation of the queue (in Bytes)
QUEUE = [];          % Size and arriving time instant of each packet in the queue

%Statistical Counters:
TOTALPACKETSvoIP= 0;   % No. of voIP packets arrived to the system
TOTALPACKETS= 0;       % No. of data packets arrived to the system
LOSTPACKETSvoIP= 0;    % No. of voIP packets dropped due to buffer overflow
LOSTPACKETS= 0;        % No. of data packets dropped due to buffer overflow
TRANSMITTEDPACKETSvoIP= 0; % No. of transmitted voIP packets
TRANSMITTEDPACKETS= 0; % No. of transmitted data packets
TRANSMITTEDBYTESvoIP= 0; % Sum of the Bytes of transmitted voIP packets
TRANSMITTEDBYTES= 0;   % Sum of the Bytes of transmitted data packets
DELAYSvoIP= 0;         % Sum of the delays of transmitted voIP packets
DELAYS= 0;             % Sum of the delays of transmitted data packets
MAXDELAYvoIP= 0;       % Maximum delay among all transmitted voIP packets
MAXDELAY= 0;           % Maximum delay among all transmitted data packets

% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first data ARRIVAL:
tmp= Clock + exprnd(1/lambda);
EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp, Data];

% Initializing the List of Events with the first voIP ARRIVAL:
for i = 1:nVoIP
    tmp= Clock + rand()*0.02;       % first arrivals between 0 and 20 miliseconds
    EventList = [EventList; ARRIVAL, tmp, GenerateVoIPPacketSize(), tmp, VoIP];
end

%Similation loop:
while (TRANSMITTEDPACKETS + TRANSMITTEDPACKETSvoIP)<P               % Stopping criterium
    EventList= sortrows(EventList,2);    % Order EventList by time
    Event= EventList(1,1);               % Get first event and 
    Clock= EventList(1,2);               %   and
    PacketSize= EventList(1,3);          %   associated
    ArrivalInstant= EventList(1,4);      %   parameters.
    packetType= EventList(1,5);          % Packet type (data or voIP)
    EventList(1,:)= [];                  % Eliminate first event

    switch Event
        case ARRIVAL                     % If first event is an ARRIVAL
            switch packetType
                case Data
                    TOTALPACKETS= TOTALPACKETS+1;
                    tmp= Clock + exprnd(1/lambda);
                    EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp, Data];
                    if STATE==0
                        STATE= 1;
                        EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock, Data];
                    else
                        if QUEUEOCCUPATION + PacketSize <= f
                            QUEUE= [QUEUE; PacketSize, Clock, Data];
                            QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                        else
                            LOSTPACKETS= LOSTPACKETS + 1;
                        end
                    end
                case VoIP
                    TOTALPACKETSvoIP= TOTALPACKETSvoIP+1;
                    tmp = Clock + (rand()*8+16) / 1000;
                    EventList = [EventList; ARRIVAL, tmp,  GenerateVoIPPacketSize(), tmp, VoIP];
                    if STATE==0
                        STATE= 1;
                        EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock, VoIP];
                    else
                        if QUEUEOCCUPATION + PacketSize <= f
                            QUEUE= [QUEUE; PacketSize, Clock, VoIP];
                            QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                        else
                            LOSTPACKETSvoIP= LOSTPACKETSvoIP + 1;
                        end
                    end
            end
        case DEPARTURE                     % If first event is a DEPARTURE
            switch packetType
                case Data
                    TRANSMITTEDBYTES= TRANSMITTEDBYTES + PacketSize;
                    DELAYS= DELAYS + (Clock - ArrivalInstant);
                    if Clock - ArrivalInstant > MAXDELAY
                        MAXDELAY= Clock - ArrivalInstant;
                    end
                    TRANSMITTEDPACKETS= TRANSMITTEDPACKETS + 1;

                case VoIP
                    TRANSMITTEDBYTESvoIP= TRANSMITTEDBYTESvoIP + PacketSize;
                    DELAYSvoIP= DELAYSvoIP + (Clock - ArrivalInstant);
                    if Clock - ArrivalInstant > MAXDELAYvoIP
                        MAXDELAYvoIP= Clock - ArrivalInstant;
                    end
                    TRANSMITTEDPACKETSvoIP= TRANSMITTEDPACKETSvoIP + 1;
            end
            if QUEUEOCCUPATION > 0
                QUEUE= sortrows(QUEUE,[3,2]);
                EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2), QUEUE(1,3)];
                QUEUEOCCUPATION= QUEUEOCCUPATION - QUEUE(1,1);
                QUEUE(1,:)= [];
            else
                STATE= 0;
            end
    end
end

%Performance parameters determination:
PLdata= 100*LOSTPACKETS/TOTALPACKETS;              % in %
PLvoIP= 100*LOSTPACKETSvoIP/TOTALPACKETSvoIP;      % in %
APDdata= 1000*DELAYS/TRANSMITTEDPACKETS;           % in milliseconds
APDvoIP= 1000*DELAYSvoIP/TRANSMITTEDPACKETSvoIP;   % in milliseconds
MPDdata= 1000*MAXDELAY;                            % in milliseconds
MPDvoIP= 1000*MAXDELAYvoIP;                        % in milliseconds

TT= 10^(-6)*(TRANSMITTEDBYTES + TRANSMITTEDBYTESvoIP)*8/Clock;  % in Mbps

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

function out= GenerateVoIPPacketSize()
    out= randi([110,130],1);
end

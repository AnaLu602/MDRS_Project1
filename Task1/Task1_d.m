%% exercicio d

% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)

lambda = 1800; %packet rate/sec
C = [10, 20, 30, 40];

packetSize = 64:1518;
prob = zeros(1,1518);
prob(packetSize) = (1 - 0.19 - 0.23 - 0.17) /(length(packetSize) - 3);
prob(64) = 0.19;
prob(110) = 0.23;
prob(1518) = 0.17;

for index = 1:length(C)
    a = packetSize * 8/(C(index) * 10^6); %%%vetor com os tempos
    b = a.^2; %%%vetor com os tempos ao quadrado
    
    E = sum(a .* prob(packetSize)); %%tempo que demora a transmitir em media 1 pacote
    E2 = sum(b .* prob(packetSize));
    
    Wq = (lambda * E2) / (2 * (1 - lambda * E));
    %%o tempo que demora na fila de espera + o tempo de transmissao media por
    %%pacote +  delay de propagaçao em segundos
    Wt = Wq + E + (C(index) * 10^-6); 

    fprintf('C = %.2e\n',C(index))
    fprintf('Av. Packet Delay (ms) = %.2e\n', Wt*1000)
    fprintf('\n')
end

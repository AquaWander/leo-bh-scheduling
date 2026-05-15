function BHST_GA(interface)
% BHST_GA Genetic Algorithm for beam-hopping scheduling
% Input:
%   interface - Simulation interface object (same as BHST_MY_SA)
% Output:
%   BHST scheduling matrix returned through interface object
% Used as a stronger baseline for comparison with TS+SA
% Date: 2026-05-12

%% GA Parameters
PopSize = 30;        % Population size
MaxGen = 50;         % Maximum generations
Pc = 0.8;            % Crossover probability
Pm = 0.2;            % Mutation probability
EliteRatio = 0.1;    % Elitism ratio
TournamentSize = 3;  % Tournament selection size

%% Get required parameters (same as BHST_MY_SA)
Radius = 6371.393e3;
heightOfsat = interface.height;
AngleOf3dB = interface.AngleOf3dB;
Rb = tools.getEarthLength(AngleOf3dB, heightOfsat)/2;

OrderOfServSatCur = interface.OrderOfServSatCur;
NumOfBeam = interface.numOfServbeam;
sche = interface.ScheInShot;
bhLength = interface.SlotInSche;
lightTime = interface.timeInSlot;

% Track transported traffic per user per scheduling period
TransportedTraffic_all = zeros(interface.NumOfSelectedUsrs, sche);

%% Traverse scheduling periods
for idx = 1 : sche
    numOfusrs = length(find(interface.usersInLine(idx,:) ~= 0));
    usersInThisSche = interface.usersInLine(idx, interface.usersInLine(idx,:) ~= 0);
    NumOfSelectedUsrs = interface.NumOfSelectedUsrs;
    OrderOfSelectedUsrs = interface.OrderOfSelectedUsrs;

    if idx == 1
        interface.tmp_UsrsTransPort = zeros(NumOfSelectedUsrs, interface.ScheInShot);
        % Pre-allocate BHST for each satellite
        for tmpSatIdx = 1:length(interface.OrderOfServSatCur)
            interface.tmpSat(tmpSatIdx).BHST = zeros(NumOfBeam, sche * bhLength);
        end
    end

    requestServAll = zeros(1, NumOfSelectedUsrs);
    if idx == 1
        for u = 1 : numOfusrs
            uIndex = find(OrderOfSelectedUsrs == usersInThisSche(u));
            requestServAll(uIndex) = interface.UsrsTraffic(uIndex,1) + interface.UsrsTraffic(uIndex,idx+1);
        end
    else
        for u = 1 : numOfusrs
            uIndex = find(OrderOfSelectedUsrs == usersInThisSche(u));
            requestServAll(uIndex) = interface.UsrsTraffic(uIndex,1) - interface.tmp_UsrsTransPort(uIndex,idx - 1) + interface.UsrsTraffic(uIndex,idx+1);
        end
    end

    %% Traverse by satellite
    for satIdx = 1 : length(interface.OrderOfServSatCur)
        curSatPos = interface.SatObj(satIdx).position;
        curSatNextPos = interface.SatObj(satIdx).nextpos;
        Pt_sat = interface.SatObj(satIdx).Pt_dBm_serv;
        Pt_sat = (10.^(Pt_sat/10))/1e3;

        numOfbeamfoot = interface.tmpSat(satIdx).NumOfBeamFoot(idx);
        servOfbeamfoot = zeros(numOfbeamfoot, 1);
        positionOfbeamfoot = zeros(numOfbeamfoot, 2);

        for bfIdx = 1 : numOfbeamfoot
            orderOfUsrs = interface.tmpSat(satIdx).beamfoot(idx, bfIdx).usrs;
            [~, interUsers] = intersect(interface.OrderOfSelectedUsrs, orderOfUsrs);
            servInBeam = requestServAll(interUsers);
            servOfbeamfoot(bfIdx) = sum(servInBeam);
            positionOfbeamfoot(bfIdx, :) = interface.tmpSat(satIdx).beamfoot(idx, bfIdx).position;
        end

        if numOfbeamfoot == 0
            BHST = zeros(NumOfBeam, bhLength);
            interface.tmpSat(satIdx).BHST(:, ((idx-1)*bhLength+1):(idx*bhLength)) = BHST(:,:);
            continue;
        end

        if numOfbeamfoot <= NumOfBeam
            BHST = zeros(NumOfBeam, bhLength);
            for j = 1 : bhLength
                for jj = 1 : numOfbeamfoot
                    BHST(jj, j) = jj;
                end
            end
            interface.tmpSat(satIdx).BHST(:,((idx-1)*bhLength+1):(idx*bhLength)) = BHST(:,:);
            fprintf('Satellite %d BHST formed\n', satIdx);
            continue;
        end

        % Interference adjacency matrix
        margin = 2 * Rb;
        distanT = zeros(numOfbeamfoot, numOfbeamfoot);
        for i = 1 : numOfbeamfoot
            for j = 1 : i
                if i ~= j
                    deltaL = tools.LatLngCoordi2Length(positionOfbeamfoot(i,:), positionOfbeamfoot(j,:), Radius);
                    if deltaL >= margin
                        distanT(i,j) = 1;
                        distanT(j,i) = 1;
                    end
                end
            end
        end

        BHST = zeros(NumOfBeam, bhLength);
        serv_need = servOfbeamfoot;

        %% Start GA for each time slot
        for slotIdx = 1 : bhLength
            scheIdx = idx;
            if isempty(find(serv_need ~= 0))
                break;
            end

            [B,I] = sort(serv_need, 'descend');
            I(find(B == 0)) = [];
            nBeam = min(NumOfBeam, length(I));
            lightPower = Pt_sat / nBeam;

            %% Initialize population
            pop = zeros(PopSize, nBeam);
            % First individual: greedy initialization with interference control
            pop(1,:) = sort(judgeBeam(nBeam, I, distanT));
            % Remaining individuals: random valid selections
            for p = 2 : PopSize
                pop(p,:) = sort(randomBeamSelect(nBeam, numOfbeamfoot, distanT));
            end

            %% Evaluate initial fitness
            fitVals = zeros(PopSize, 1);
            for p = 1 : PopSize
                fitVals(p) = funcFit(satIdx, scheIdx, slotIdx, pop(p,:), interface, serv_need, curSatPos, curSatNextPos, heightOfsat);
            end

            %% Evolution
            nElite = max(1, round(EliteRatio * PopSize));
            bestIdx = find(fitVals == min(fitVals), 1);
            bestSol = pop(bestIdx,:);
            bestFit = fitVals(bestIdx);

            for gen = 1 : MaxGen
                %% Selection (tournament)
                newPop = zeros(PopSize, nBeam);
                % Elitism: keep best individuals
                [~, sortedIdx] = sort(fitVals);
                for e = 1 : nElite
                    newPop(e,:) = pop(sortedIdx(e),:);
                end

                for p = (nElite+1) : PopSize
                    % Tournament selection
                    candidates = randperm(PopSize, TournamentSize);
                    [~, winner] = min(fitVals(candidates));
                    parent1 = pop(candidates(winner),:);

                    candidates = randperm(PopSize, TournamentSize);
                    [~, winner] = min(fitVals(candidates));
                    parent2 = pop(candidates(winner),:);

                    %% Crossover (uniform)
                    if rand() < Pc
                        child = zeros(1, nBeam);
                        mask = rand(1, nBeam) < 0.5;
                        child(mask) = parent1(mask);
                        child(~mask) = parent2(~mask);
                        % Repair: remove duplicates and fill with random beams
                        child = repairChild(child, numOfbeamfoot, distanT);
                    else
                        child = parent1;
                    end

                    %% Mutation (swap one beam)
                    if rand() < Pm
                        mutIdx = randi(nBeam);
                        attempts = 0;
                        while attempts < 20
                            newBeam = randi(numOfbeamfoot);
                            if ~ismember(newBeam, child) && checkInterference(child, mutIdx, newBeam, distanT)
                                child(mutIdx) = newBeam;
                                break;
                            end
                            attempts = attempts + 1;
                        end
                    end

                    newPop(p,:) = sort(child);
                end

                pop = newPop;

                %% Evaluate fitness
                for p = 1 : PopSize
                    fitVals(p) = funcFit(satIdx, scheIdx, slotIdx, pop(p,:), interface, serv_need, curSatPos, curSatNextPos, heightOfsat);
                end

                %% Update best
                curBestIdx = find(fitVals == min(fitVals), 1);
                if fitVals(curBestIdx) < bestFit
                    bestSol = pop(curBestIdx,:);
                    bestFit = fitVals(curBestIdx);
                end
            end

            % Record best solution
            BHST(:,slotIdx) = bestSol';

            % Update traffic and record transported traffic per user
            for cc = 1 : length(bestSol)
                curFoot = bestSol(cc);
                beforeServ = max(serv_need(curFoot), 0);
                leftServ = calcuServ(satIdx, scheIdx, slotIdx, bestSol, curFoot, interface, serv_need, curSatPos, curSatNextPos, heightOfsat);
                if length(leftServ) == 1
                    actualServed = max(beforeServ - leftServ, 0);
                    serv_need(curFoot) = leftServ;
                    % Distribute to users in this beam proportionally to remaining demand
                    orderOfUsrs = interface.tmpSat(satIdx).beamfoot(idx, curFoot).usrs;
                    [~, interUsers] = intersect(interface.OrderOfSelectedUsrs, orderOfUsrs);
                    if ~isempty(interUsers)
                        userDemands = max(requestServAll(interUsers), 0);
                        userDemands = userDemands(:);
                        alreadyServed = TransportedTraffic_all(interUsers, idx);
                        alreadyServed = alreadyServed(:);
                        remainingDemand = max(userDemands - alreadyServed, 0);
                        totalRemaining = sum(remainingDemand);
                        if totalRemaining > 0
                            distributeNow = min(actualServed, totalRemaining);
                            for u = 1 : length(interUsers)
                                TransportedTraffic_all(interUsers(u), idx) = TransportedTraffic_all(interUsers(u), idx) + ...
                                    distributeNow * (remainingDemand(u) / totalRemaining);
                            end
                        end
                    end
                end
            end
            fprintf('Satellite %d BHST(GA) formed %.1f%%\n', satIdx, slotIdx * 100 / bhLength);
        end

        interface.tmpSat(satIdx).BHST(:,((idx-1)*bhLength+1):(idx*bhLength)) = BHST(:,:);
        fprintf('Scheduling %d Satellite %d BHST(GA) formed\n', idx, satIdx);
    end
end

% Write transported traffic to interface
interface.tmp_UsrsTransPort = TransportedTraffic_all;

end

%% Greedy beam selection with interference control (same as BHST_MY_SA)
function curBeam = judgeBeam(maxBeam, I, distanT)
curBeam = zeros(1, maxBeam);
curBeam(1) = I(1);
II = I;
II(1) = [];

count = 2;
while true
    if isempty(II)
        if count ~= maxBeam + 1
            III = I;
            [~,ia,~] = intersect(III, curBeam);
            III(ia) = [];
            leftNum = maxBeam - (count - 1);
            if length(III) < leftNum
                curBeam(count:end) = III;
            else
                curBeam(count:end) = III(1:leftNum);
            end
            return;
        else
            return;
        end
    elseif count == maxBeam + 1 && ~isempty(II)
        return;
    end
    curBeam(count) = II(1);
    flag = 0;
    for k = 1 : count - 1
        if distanT(curBeam(k), curBeam(count)) == 0
            flag = 1;
            break;
        end
    end
    if flag == 1
        II(1) = [];
        curBeam(count) = 0;
    else
        II(1) = [];
        count = count + 1;
    end
end
end

%% Random beam selection with interference awareness
function beams = randomBeamSelect(nBeam, numOfbeamfoot, distanT)
beams = zeros(1, nBeam);
selected = randperm(numOfbeamfoot);
count = 0;
for i = 1 : numOfbeamfoot
    if count >= nBeam
        break;
    end
    candidate = selected(i);
    valid = true;
    for j = 1 : count
        if distanT(beams(j), candidate) == 0
            valid = false;
            break;
        end
    end
    if valid
        count = count + 1;
        beams(count) = candidate;
    end
end
% If not enough interference-free beams, fill with remaining
if count < nBeam
    remaining = setdiff(1:numOfbeamfoot, beams(1:count));
    beams(count+1:nBeam) = remaining(1:nBeam-count);
end
end

%% Repair child after crossover
function child = repairChild(child, numOfbeamfoot, distanT)
% Remove duplicates
[~, ia, ic] = unique(child);
duplicates = setdiff(1:length(child), ia);
nBeam = length(child);

for d = duplicates
    attempts = 0;
    while attempts < 30
        newBeam = randi(numOfbeamfoot);
        if ~ismember(newBeam, child)
            child(d) = newBeam;
            break;
        end
        attempts = attempts + 1;
    end
end

% Ensure all beams are distinct
while length(unique(child)) < nBeam
    dupes = child;
    for i = 1 : nBeam
        for j = i+1 : nBeam
            if child(i) == child(j)
                attempts = 0;
                while attempts < 30
                    newBeam = randi(numOfbeamfoot);
                    if ~ismember(newBeam, child)
                        child(j) = newBeam;
                        break;
                    end
                    attempts = attempts + 1;
                end
            end
        end
    end
end
child = sort(child);
end

%% Check interference for a specific position
function valid = checkInterference(beams, replaceIdx, newBeam, distanT)
valid = true;
for i = 1 : length(beams)
    if i ~= replaceIdx && distanT(beams(i), newBeam) == 0
        valid = false;
        return;
    end
end
end

%% Calculate remaining traffic for a beam position (same as BHST_MY_SA)
function leftServ = calcuServ(SatIdx, ScheIdx, slotIdx, lightFoot, curFoot, interface, serv_need, curSatPos, curSatNextPos, heightOfsat)
NumOfLightBeamfoot = length(lightFoot);
Pt_sat = interface.SatObj(SatIdx).Pt_dBm_serv;
Pt_sat = (10.^(Pt_sat/10))/1e3;
lightPower = Pt_sat / NumOfLightBeamfoot;
Band = interface.BandOfLink * 1e6;
freqOfDownLink = interface.freqOfDownLink;
startOfBand = freqOfDownLink - Band / 2;
lightTime = interface.timeInSlot;

PosOfBeam = zeros(NumOfLightBeamfoot, 2);
for bidx = 1 : NumOfLightBeamfoot
    PosOfBeam(bidx,:) = interface.tmpSat(SatIdx).beamfoot(ScheIdx, lightFoot(bidx)).position;
end

BeamPoint = zeros(NumOfLightBeamfoot, 2);
for j = 1 : NumOfLightBeamfoot
    [outputTheta, outputPhi] = tools.getPointAngleOfUsr(...
        curSatPos, curSatNextPos, PosOfBeam(j,:), heightOfsat);
    BeamPoint(j,1) = outputPhi;
    BeamPoint(j,2) = outputTheta;
end

orderOfUsrs = interface.tmpSat(SatIdx).beamfoot(ScheIdx, curFoot).usrs;
curSINR = 0;
subBandWidth = Band / length(orderOfUsrs);
for usrIdx = 1 : length(orderOfUsrs)
    curUser = orderOfUsrs(usrIdx);
    tmpBand = [startOfBand + (usrIdx-1)*subBandWidth, startOfBand + usrIdx*subBandWidth];
    thisSINR = CaculateSINR(SatIdx, ScheIdx, slotIdx, curUser, curFoot, lightFoot, lightPower, BeamPoint, tmpBand, interface);
    curSINR = curSINR + thisSINR;
end
SINRofBF = curSINR / length(orderOfUsrs);

given = Band * log2(1+SINRofBF) * lightTime;
footIdx = find(lightFoot == curFoot);
leftServ = serv_need(curFoot) - given;
end

%% Calculate fitness value (same as BHST_MY_SA)
function fitValue = funcFit(SatIdx, ScheIdx, slotIdx, lightFoot, interface, serv_need, curSatPos, curSatNextPos, heightOfsat)
NumOfLightBeamfoot = length(lightFoot);
SINRofBF = zeros(1, NumOfLightBeamfoot);
Pt_sat = interface.SatObj(SatIdx).Pt_dBm_serv;
Pt_sat = (10.^(Pt_sat/10))/1e3;
lightPower = Pt_sat / NumOfLightBeamfoot;
Band = interface.BandOfLink * 1e6;
freqOfDownLink = interface.freqOfDownLink;
startOfBand = freqOfDownLink - Band / 2;
lightTime = interface.timeInSlot;

PosOfBeam = zeros(NumOfLightBeamfoot, 2);
for bidx = 1 : NumOfLightBeamfoot
    PosOfBeam(bidx,:) = interface.tmpSat(SatIdx).beamfoot(ScheIdx, lightFoot(bidx)).position;
end

BeamPoint = zeros(NumOfLightBeamfoot, 2);
for j = 1 : NumOfLightBeamfoot
    [outputTheta, outputPhi] = tools.getPointAngleOfUsr(...
        curSatPos, curSatNextPos, PosOfBeam(j,:), heightOfsat);
    BeamPoint(j,1) = outputPhi;
    BeamPoint(j,2) = outputTheta;
end

for footIdx = 1 : NumOfLightBeamfoot
    curFoot = lightFoot(footIdx);
    orderOfUsrs = interface.tmpSat(SatIdx).beamfoot(ScheIdx, curFoot).usrs;
    curSINR = 0;
    subBandWidth = Band / length(orderOfUsrs);
    for usrIdx = 1 : length(orderOfUsrs)
        curUser = orderOfUsrs(usrIdx);
        tmpBand = [startOfBand + (usrIdx-1)*subBandWidth, startOfBand + usrIdx*subBandWidth];
        thisSINR = CaculateSINR(SatIdx, ScheIdx, slotIdx, curUser, curFoot, lightFoot, lightPower, BeamPoint, tmpBand, interface);
        curSINR = curSINR + thisSINR;
    end
    SINRofBF(footIdx) = curSINR / length(orderOfUsrs);
end

serv_left = serv_need;
for footIdx = 1 : NumOfLightBeamfoot
    curFoot = lightFoot(footIdx);
    given = Band * log2(1+SINRofBF(footIdx)) * lightTime;
    serv_left(curFoot) = serv_left(curFoot) - given;
end

fitValue = sum(serv_left);
end

%% Calculate SINR for a specific user (same as BHST_MY_SA)
function SINR = CaculateSINR(SatIdx, ScheIdx, slotIdx, userIdx, curFoot, lightFoot, lightPower, BeamPoint, thisBand, interface)
Usrs = interface.tmpSat(SatIdx).beamfoot(ScheIdx, curFoot).usrs;
footIdx = find(lightFoot == curFoot);
Pt = 1 / length(Usrs) * lightPower;
Band = interface.BandOfLink * 1e6;

Bandwidth = Band / length(Usrs);
freqOfDownLink = interface.freqOfDownLink;
startOfBand = freqOfDownLink - Band / 2;
userIdxInBeam = find(Usrs == userIdx);
thisBand = [startOfBand + (userIdxInBeam-1)*Bandwidth, startOfBand + userIdxInBeam*Bandwidth];
fc = mean(thisBand);

userCurPos = interface.UsrsObj(userIdx).position;
satCurPos = interface.SatObj(SatIdx).position;
satCurnextPos = interface.SatObj(SatIdx).nextpos;
[userTheta, userPhi] = tools.getPointAngleOfUsr(satCurPos, satCurnextPos, userCurPos, interface.height);
G_usrDown = antenna.getUsrAntennaServG(0, fc, false);
usrCurPos = interface.UsrsObj(userIdx).position;
usrPosInDescartes = LngLat2Descartes(usrCurPos, 0);
satPosInDescartes = LngLat2Descartes(satCurPos, interface.height);
distance = sqrt((satPosInDescartes(1)-usrPosInDescartes(1)).^2 + ...
                (satPosInDescartes(2)-usrPosInDescartes(2)).^2 + ...
                (satPosInDescartes(3)-usrPosInDescartes(3)).^2);
InterfInSatDown = 0;

for bfIdx = 1 : length(lightFoot)
    OrderOfbeam = lightFoot(bfIdx);
    if OrderOfbeam == curFoot
        continue;
    else
        interfUsrs = interface.tmpSat(SatIdx).beamfoot(ScheIdx, OrderOfbeam).usrs;
        interfBeamPower = lightPower;
        poiBeta = BeamPoint(bfIdx,1);
        poiAlpha = BeamPoint(bfIdx,2);
        AgleOfInv = [userTheta, userPhi];
        AgleOfPoi = [poiAlpha, poiBeta];

        subBandWidth = Band / length(interfUsrs);
        for interfUsrIdx = 1 : length(interfUsrs)
            thisInterfUser = interfUsrs(interfUsrIdx);
            thisInterfUser_power = 1 / length(interfUsrs) * interfBeamPower;
            thisInterfUser_band = [startOfBand + (interfUsrIdx-1)*subBandWidth, startOfBand + interfUsrIdx*subBandWidth];

            overlap = range_intersection(thisBand, thisInterfUser_band);
            if length(overlap) == 2
                lambdaDown = 3e8/mean(overlap);
                G_sat_interfDown = antenna.getSatAntennaServG(AgleOfInv, AgleOfPoi, mean(overlap));
                InterfInSatDown = InterfInSatDown + ...
                    thisInterfUser_power * G_sat_interfDown * G_usrDown * (lambdaDown.^2) / (((4*pi).^2)*(distance.^2));
            end
        end
    end
end

bfIdx = find(lightFoot == curFoot);
poiBeta = BeamPoint(bfIdx,1);
poiAlpha = BeamPoint(bfIdx,2);
AgleOfInv = [userTheta, userPhi];
AgleOfPoi = [poiAlpha, poiBeta];
lambda_c = 3e8/fc;

G_sat_down = antenna.getSatAntennaServG(AgleOfInv, AgleOfPoi, fc);

Carrier_down = Pt * G_sat_down * G_usrDown * (lambda_c.^2) / (((4*pi).^2)*(distance.^2));
SINR = Carrier_down ./ (InterfInSatDown + 1.380649e-23 * 300 * Bandwidth);
end

%%
function PosInDescartes = LngLat2Descartes(CurPos, h)
    tmpPhi = CurPos(1) * pi / 180;
    if tmpPhi < 0
        tmpPhi = tmpPhi + 2*pi;
    end
    tmpTheta = (90 - CurPos(2)) * pi / 180;
    R = 6371.393e3;
    tmpX = (R+h) * sin(tmpTheta) * cos(tmpPhi);
    tmpY = (R+h) * sin(tmpTheta) * sin(tmpPhi);
    tmpZ = (R+h) * cos(tmpTheta);
    PosInDescartes = [tmpX, tmpY, tmpZ];
end

%% Calculate intersection
function [Overlap] = range_intersection(A, B)
Lower_A = min(A);
Upper_A = max(A);
Lower_B = min(B);
Upper_B = max(B);

if (Lower_A > Lower_B || Lower_A == Lower_B)
    Lower_Lim = Lower_A;
else
    Lower_Lim = Lower_B;
end

if (Upper_A > Upper_B || Upper_A == Upper_B)
    Upper_Lim = Upper_B;
else
    Upper_Lim = Upper_A;
end

input_vector = union(A,B);
Overlap = input_vector(intersect(find(input_vector >= Lower_Lim), find(input_vector <= Upper_Lim)));
end

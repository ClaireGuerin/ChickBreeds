%% Claire Guerin - 11/07/2017

% Import data

[FileName,PathName] = uigetfile('*.mat','Select the tracking file');
cd(PathName)
S = load(FileName);
trackingData = S.trackingData;
tags = S.tags;
nFrames = size(trackingData,1);

%% Smooth tracking

fRate = 1/100; % here distance (cm) travelled between 2 consecutive frames = speed (cm/sec) since the frequency is 1 (1 frame per
% sec). If used a video subset, change fRate accordingly (e.g. 1/100).

failPercRaw = trackFail(trackingData); % average percentage of frame where individuals are lost - Raw Data
maxGapInSec = 2;
maxGap = fRate * maxGapInSec;
trackingDataSmooth = fixShortNanGaps(trackingData,maxGap);
failPercSmooth = trackFail(trackingDataSmooth); % reduced from 16.7% to 2.5% identification fail =)

%% Get average speed and remove outliers - IN CONSTRUCTION

figure

for indiv = 1:size(trackingDataSmooth,2)
    subplot(3,2,indiv)
    plot(trackingDataSmooth(:,indiv,1),trackingDataSmooth(:,indiv,2))
end

scaleFactor = 0.115;
stepwiseDist = nan(size(trackingDataSmooth,1),size(trackingDataSmooth,2),size(trackingDataSmooth,3)/2);

for timeStep = 1:(nFrames - 1)
    x0 = trackingDataSmooth(timeStep,:,[1,3]);
    x1 = trackingDataSmooth(timeStep+1,:,[1,3]);
    y0 = trackingDataSmooth(timeStep,:,[2,4]);
    y1 = trackingDataSmooth(timeStep+1,:,[2,4]);
    
    stepwiseDist(timeStep,:,:) = sqrt((x1 - x0).^2 + (y1 - y0).^2) * scaleFactor * fRate;
end

figure
speedCenter = stepwiseDist(:,:,1);
speedFront = stepwiseDist(:,:,2);

subplot(2,1,1)
boxplot(speedCenter)
h = findobj(gcf,'tag','Outliers');

subplot(2,1,2)
boxplot(speedFront)

%%

datName = 'g12d1_tracked.mat';

nComb = 6*5/2; % number of individuals combinations, no rep
trueFrmNum = ceil(linspace(100,10833,100)); % this is to use only if the video is a video subset

tagsTable = csvread('taglist.csv');
tableColumns = string({'Individual','Group','Breed','Pair','Day1','Day2','Day3'});
group = str2double(datName(2:end-14));
day = ['Day',datName(5)];

indiv = ismember(tagsTable(:,tableColumns == day),tags) & tagsTable(:,tableColumns == 'Group') == group;

tags = tagsTable(tagsTable(:,tableColumns == 'Group') == 12,tableColumns == day);
pair = tagsTable(tagsTable(:,tableColumns == 'Group') == 12,tableColumns == 'Pair');
% pairColors = {'k','k','c','c','m','m'};
pairColors = [[0,0,0];[0,0,0];[0,1,1];[0,1,1];[1,0,1];[1,0,1]];

nodNames = tagsTable(tagsTable(:,tableColumns == 'Group') == group ,1);
indivPairs = nchoosek(1:6,2);

% v = VideoWriter('NetworkTest.avi');
% open(v)

fRate = 1/100; % here with the subset, 1 frame captured every 100 second
distances = nan(nFrames, nComb);

for frm = 1:nFrames
    %     frm = 1;
    x = trackingDataSmooth(frm,:,1) ;
    y = trackingDataSmooth(frm,:,2) ;
    
    distances(frm,:) = pdist([x',y']) * scaleFactor;
end

nFirstFrames = 30*60*fRate;
firstHalfHour = reshape(1:nFirstFrames - rem(nFirstFrames,6),[floor(nFirstFrames/6),6]);

nRestFrames = nFrames - 30*60*fRate;
endExperiment = reshape((30*60*fRate+1):nFrames - rem(nRestFrames,5),[floor(nRestFrames/5),5]);

figure
for network = 1:12
%     network = 1;
    if network < 7
        
        meanDist = nanmean(distances(firstHalfHour(:,network),:),1);
        graphTitle = ['t = ', num2str(firstHalfHour(end,network)/fRate),' seconds'];
        
    elseif network < 12
        
        meanDist = nanmean(distances(endExperiment(:,network-6),:),1);
        graphTitle = [ 't = ', num2str(endExperiment(end,network-6)/fRate), ' seconds'];
        
    else
        
        meanDist = nanmean(distances,1);
        graphTitle = 'Overall average network';
        
    end
    
    G = graph(indivPairs(:, 1),indivPairs(:, 2));
    G.Nodes.Names = string(nodNames);
    G.Nodes.Colors = pairColors;
    
    G.Edges.Weight = meanDist';
    G2 = rmedge(G,find(isnan(meanDist)));
    G2.Edges.NormWeight = G2.Edges.Weight/sum(G2.Edges.Weight);
    LWidths = 5*G2.Edges.Weight/max(G2.Edges.Weight);
    
    subplot(3,4,network)
    p = plot(G2,'Layout','circle','EdgeLabel',ceil(G2.Edges.Weight),'LineWidth',LWidths,'EdgeColor', [105/250,105/250,105/250],'NodeLabel',cellstr(G2.Nodes.Names),'NodeColor',G.Nodes.Colors);
    title(graphTitle)
    axis equal
    set(gca,'xtick',[],'ytick',[])
    p.MarkerSize = 10;
    
end

%     F = getframe(fig);
%     writeVideo(v,F)
%     pause(0.1)

% close(v)

histogram(distances)
% seems like the chicks tend to stay in group most of the time.
% Outliers (>600px distance) might be due to the distance between chicks at the beginning of the experiment

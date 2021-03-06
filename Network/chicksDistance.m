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

distances = nan(nFrames, 6*5/2);
trueFrmNum = ceil(linspace(100,10833,100));

fig = figure('Visible', 'on'); 
indivPairs = nchoosek(1:6,2);

v = VideoWriter('NetworkTest.avi');
open(v)

for frm = 1:nFrames
    im = read(vid,frm);
    x = trackingData(frm,:,1) ;
    y = trackingData(frm,:,2) ;
    
    distances(frm,:) = pdist([x',y']);
    
    G = graph(indivPairs(:, 1),indivPairs(:, 2));

    G.Edges.Weight = distances(frm,:)';
    G2 = rmedge(G,find(isnan(distances(frm,:))));
    G2.Edges.NormWeight = G2.Edges.Weight/sum(G2.Edges.Weight);
    LWidths = 5*G2.Edges.Weight/max(G2.Edges.Weight);
    
    p = plot(G2,'Layout','circle','EdgeLabel',ceil(G2.Edges.Weight),'LineWidth',LWidths);
    title(['Frame: ',num2str(trueFrmNum(frm))])
    axis equal

%     imshow(im)
%     hold on
%     plot(x, y)
%     hold off

    F = getframe(fig);
    writeVideo(v,F)
    pause(0.1)
end

close(v)

% G.Nodes.Name = cellstr(string(tags));

histogram(distances) 
% seems like the chicks tend to stay in group most of the time. 
% Outliers (>600px distance) might be due to the distance between chicks at the beginning of the experiment 

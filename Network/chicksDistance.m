%% Claire Guerin - 11/07/2017

% Import data

[FileName,PathName] = uigetfile('*.mat','Select the tracking file');
cd(PathName)
S = load(FileName);
trackingData = S.trackingData;
tags = S.tags;
nFrames = size(trackingData,1);

%% Get average speed and remove outliers

coordZero = trackingData(1,:,:);

meanDist = nanmean(trackingData,2);

%% Smooth tracking

failPercRaw = trackFail(trackingData); % average percentage of frame where individuals are lost - Raw Data 


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

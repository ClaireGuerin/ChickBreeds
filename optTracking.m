function [trackingData,tags] = optTracking(vidName)
%% Claire Guerin - 13/07/2017
% Read video and track chicks

vid = VideoReader(vidName);
nFrames = vid.NumberOfFrames;
tags = csvread([vidName,'_tags.csv']);
nTags = numel(tags);

xCenter = nan(nFrames, nTags);
yCenter = nan(nFrames, nTags);
xFront = nan(nFrames, nTags);
yFront = nan(nFrames, nTags);

comb = combvec(linspace(1,20,20), linspace(0.5,10,20));
nComb = size(comb, 2);
parS = comb(1,:);
parT = comb(2,:);

parfor i = 1:nFrames
    try
        im = read(vid,i);
        
        nTrackIndiv = 0;
        bestSoFar = 1;
        
        for combination = 1:nComb
            
            bradSize = parS(combination);
            bradThre = parT(combination);
                    
            tmpCodes = locateCodes(im, 'vis', 0, 'threshMode', 1, 'bradleyFilterSize', [bradSize, bradSize], 'bradleyThreshold', bradThre, 'tagList', tags);
            
            nTrackIndivNew = size(tmpCodes, 1);
            
            if nTrackIndivNew == 6
                bestSoFar = combination;
                break
                
            elseif nTrackIndivNew > nTrackIndiv
                nTrackIndiv = nTrackIndivNew;
                bestSoFar = combination;
                continue
            end
            
        end

        R = locateCodes(im, 'threshMode', 1, 'bradleyThreshold', parT(bestSoFar), 'bradleyFilterSize', [parS(bestSoFar),parS(bestSoFar)], 'vis', 0, 'tagList', tags);
        rtags = [R.number];
        
        for j = 1:nTags
            
            rt = R(rtags == tags(j));
            
            if numel(rt) == 1
                xCenter(i,j) = rt.Centroid(1);
                yCenter(i,j) = rt.Centroid(2);
                xFront(i,j) = rt.frontX;
                yFront(i,j) = rt.frontY;
            end
        end
    catch
        continue
    end
end

trackingData = nan(nFrames, nTags, 4);
trackingData(:,:,1) = xCenter;
trackingData(:,:,2) = yCenter;
trackingData(:,:,3) = xFront;
trackingData(:,:,4) = yFront;
end
[FileName,PathName] = uigetfile('*.avi','Select the video file');
cd(PathName)

vid = VideoReader([PathName,FileName]);
nFrames = vid.NumberOfFrames;
tags = csvread([FileName(1:end-4), '_tags.csv']);
selectFrames = ceil(linspace(100,nFrames,10));
 
% im = read(vid,100);
% imshow(im)
%%

sizes = linspace(1,20,20);
thresh = linspace(0.5,10,20);
comb = combvec(sizes, thresh);
n = size(comb, 2);
test = nan(1,n);
bestComb = [];
figure('Visible','off');

for frm = selectFrames
    im = read(vid,frm);
    for i = 1:n
        tempFilterSize = comb(1,i);
        tempBradleyThreshold = comb(2,i);
        tempCodes = locateCodes(im, 'vis', 0, 'threshMode', 1, 'bradleyFilterSize', [tempFilterSize,tempFilterSize], 'bradleyThreshold', tempBradleyThreshold, 'tagList', tags);

        test(1,i) = size(tempCodes, 1);
    end
    
    bestComb = [bestComb, comb(:,test == numel(tags))];
end

csvwrite([FileName,'_Bradley.csv.'], [mode(bestComb(1,:));mode(bestComb(2,:))])




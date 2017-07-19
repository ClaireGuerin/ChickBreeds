PathName = '\\cimec-storage2\acn_lab\ABC\animal-cognition-genetics\pulcini\2017\razze_tag6pulcini\Day2';
cd(PathName)
vidList = dir('*.avi');

nVid = size(vidList,1);
scale = nan(nVid,1);

for vidNum = 1:nVid
    vid = VideoReader(vidList(vidNum).name);
    im = readFrame(vid);
    imshow(im)
    [X, Y] = ginput(2);
    close
    cmPerPx = 115 / sqrt((X(1) - X(2))^2 + (Y(1) - Y(2))^2);
    scale(vidNum) = cmPerPx;
end

hist(scale)

% scale between 0.111 cm/px and 0.119 cm/px. Let's just take 0.115.
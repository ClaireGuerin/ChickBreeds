function videoSubset(oldVid, outFile, subsize, start)
%% Create video subset

if nargin < 4
    start = 1;
end

nfrm = oldVid.NumberOfFrames;
selectfrm = ceil(linspace(start,nfrm,subsize));

newVid = VideoWriter([outFile,'.avi']);
open(newVid)

for frm = selectfrm
    im = rgb2gray(read(oldVid,frm));
    writeVideo(newVid,im)
end

close(newVid)
end
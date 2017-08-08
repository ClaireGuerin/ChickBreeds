[FileName,PathName] = uigetfile('*.avi','Select the video file');
cd(PathName)

vid = VideoReader(FileName);
nFrames = vid.NumberOfFrames;
disp(nFrames)
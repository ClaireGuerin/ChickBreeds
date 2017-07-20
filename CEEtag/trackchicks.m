% Claire Guerin - 14/07/2017
% Script for tracking 6 chicks breeds

% Get list of video files to analyse

PathName = '/n/regal/debivort_lab/claire/pulcini/Day1/';
fileList = dir([PathName,'*.avi']);

% Set up parallel computing
pc = parcluster('local') ;
pc.JobStorageLocation = strcat('/scratch/cguerin/', getenv('SLURM_JOB_ID'));
parpool(pc, 32)

% Loop through files and track chicks
for f = 1:numel(fileList)
	fileName = [PathName, fileList(f).name];
    
    try
        [trackingData, tags] = optTracking(fileName);
    catch
        warning(['Tracking failed for file ',fileName,'. Assigning NaNs.']);
        trackingData = NaN;
        tags = NaN;
    end
    
    save(strcat(fileName, '_tracked.mat'), 'trackingData', 'tags')
end
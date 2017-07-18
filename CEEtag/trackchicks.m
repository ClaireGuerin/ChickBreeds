% Claire Guerin - 14/07/2017
% Script for tracking 6 chicks breeds

% Get list of video files to analyse

fileList = dir('/n/regal/debivort_lab/claire/pulcini/Day2/*.avi');

% Set up parallel computing
pc = parcluster('local') ;
pc.JobStorageLocation = strcat('/scratch/claire/', getenv('SLURM_JOB_ID'));
parpool(pc, 32)

% Loop through files and track chicks
for f = 1:numel(fileList)
	fileName = fileList(f).name;
    
    try
        [trackingData, tags] = optTracking(fileName);
    catch
        warning(['Tracking failed for file ',fileName,'. Assigning NaNs.']);
        trackingData = NaN;
        tags = NaN;
    end
    
    save(strcat(fileName, '_tracked.mat'), 'trackingData', 'tags')
end
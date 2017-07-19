% Claire Guerin - 14/07/2017
% Script for tracking 6 chicks breeds

% Get list of video files to analyse

PathName = '/n/regal/debivort_lab/claire/pulcini/Day1/';
fileList = dir([PathName,'*.avi']);

% Set up parallel computing
pc = parcluster('local') ;
pc.JobStorageLocation = strcat('/scratch/claire/', getenv('SLURM_JOB_ID'));
parpool(pc, 32)

w = fopen([PathName,'warnings.txt'],'wt');

% Loop through files and track chicks
for f = 1:numel(fileList)
    fileName = fileList(f).name;
	filePath = [PathName, fileName];
    
    try
        [trackingData, tags] = optTracking(filePath);
    catch
        fprintf(w, ['Tracking failed for file ',filePath,'. Assigning NaNs.\n']);
        trackingData = NaN;
        tags = NaN;
    end
    
    save(strcat(fileName, '_tracked.mat'), 'trackingData', 'tags')
end

fclose(w);
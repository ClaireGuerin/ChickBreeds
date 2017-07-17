function totAv = trackFail(trackArray)
% Claire Guérin - 12/07/2017
% Little function that calculates the occurence percentage of tracking failure

indAv = mean(isnan(trackArray),1);
totAv = mean(indAv(1,:,1))*100;

end

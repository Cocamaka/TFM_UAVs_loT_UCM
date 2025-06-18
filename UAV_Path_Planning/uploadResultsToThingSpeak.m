function uploadResultsToThingSpeak(final_params, channelID_input)
    channelID = channelID_input;      
    writeAPIKey = '3TI4HIBQBWRVBWTP'; 
    
    workingDistance_m = final_params.pathMetrics.WorkingPathLength;       
    
    totalDistance_m = final_params.pathMetrics.TotalPathLength;           
                                                                          
                                                                          
    travelDistance_m = final_params.pathMetrics.TravelPathLength;       
                                                                         
                                                                          
    acoTSP_Distance_m = final_params.pathMetrics.EstimatedTravelDistanceACO;
    
    workingTime_min = final_params.pathMetrics.WorkingOperationTime / 60;
    totalTime_min = final_params.pathMetrics.TotalOperationTime / 60;  
    
    workingTurns_count = final_params.pathMetrics.WorkingTurnCount;
    totalTurns_count = final_params.pathMetrics.TotalTurnCount;           

    dataToWrite = [workingDistance_m, totalDistance_m, travelDistance_m, acoTSP_Distance_m, ...
                   workingTime_min, totalTime_min, workingTurns_count, totalTurns_count];

    try
        response = thingSpeakWrite(channelID, dataToWrite, 'WriteKey', writeAPIKey, 'Timeout', 30);
        if isnumeric(response) && response > 0
            fprintf('OKKKKKK: %d\n', response);
        else
            fprintf('Emmmmm: %s\n', char(response));
        end
    catch ME
        fprintf('NOOOOOO: %s\n', ME.message);
        disp(ME.stack(1));
    end
end
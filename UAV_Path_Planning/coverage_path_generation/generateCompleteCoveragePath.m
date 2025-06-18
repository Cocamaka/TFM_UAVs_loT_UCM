function fullPath = generateCompleteCoveragePath(params)

    subregions_all = params.subregions;
    optimal_sequence_indices = params.optimalSequence;
    drone = params.drone;
    gridMap = params.gridMap;
    gridResolution = params.gridResolution;
    mapOrigin = params.mapOrigin;
    mapSize = params.mapSize;
    
    droneAltitude = drone.Altitude;
    droneWidth = drone.Width;
    shouldReturnToHome = drone.ReturnToHome;
    tolerance = 1e-6;
    
    PATH_TYPE_START = 1;
    PATH_TYPE_WORK = 2;
    PATH_TYPE_TURN = 3;
    PATH_TYPE_TRAVEL = 4;
    PATH_TYPE_END = 5;
    PATH_TYPE_RETURN = 6;
    
    % Inicializar
    startPoint_00_3D = [0, 0, droneAltitude];
    fullPathWaypoints = [startPoint_00_3D, PATH_TYPE_START, 0]; % [x,y,z, tipo, id_subregion]
    currentDronePosition = startPoint_00_3D;
    lastValidExitPointForReturn = currentDronePosition; % Para el regreso al inicio
    
    % Recorrer subregiones en orden óptimo
    for i_seq = 1:length(optimal_sequence_indices)
        subregion_idx_in_all = optimal_sequence_indices(i_seq);
        current_subregion = subregions_all{subregion_idx_in_all};
        currentSubregionActualID = current_subregion.ID; 
        
        [subregion_coverage_waypoints_raw, ~, ~] = generateBoustrophedonCoverageForSubregion(...
            current_subregion.Vertices, droneWidth, droneAltitude, current_subregion.OptimalSweepAngle);
        
        subregion_coverage_waypoints_typed = subregion_coverage_waypoints_raw;
        subregion_coverage_waypoints_typed(:,5) = currentSubregionActualID; 
        
        actualCoverageEntryPt = subregion_coverage_waypoints_typed(1, 1:3);
        actualCoverageExitPt = subregion_coverage_waypoints_typed(end, 1:3);
        
        travelPathToSubregion_3D = findAStarPathBetweenPoints(currentDronePosition, actualCoverageEntryPt, ...
            droneAltitude, gridMap, gridResolution, mapOrigin, mapSize);
        
        travel_types = PATH_TYPE_TRAVEL * ones(size(travelPathToSubregion_3D,1)-1, 1);
        travel_sub_ids = zeros(size(travelPathToSubregion_3D,1)-1, 1); 
        fullPathWaypoints = [fullPathWaypoints; travelPathToSubregion_3D(2:end, 1:3), travel_types, travel_sub_ids];
        
        fullPathWaypoints = [fullPathWaypoints; subregion_coverage_waypoints_typed(2:end,:)]; 
        
        currentDronePosition = actualCoverageExitPt;
        lastValidExitPointForReturn = currentDronePosition;
    end
    
    finalDronePosition = currentDronePosition; 
    
    if shouldReturnToHome
        disp('Planificando ruta de regreso al punto de inicio');
        returnPathToOrigin_3D = findAStarPathBetweenPoints(lastValidExitPointForReturn, startPoint_00_3D, ...
            droneAltitude, gridMap, gridResolution, mapOrigin, mapSize);
        
        return_types = PATH_TYPE_RETURN * ones(size(returnPathToOrigin_3D,1)-1, 1);
        return_sub_ids = zeros(size(returnPathToOrigin_3D,1)-1, 1); 
        fullPathWaypoints = [fullPathWaypoints; returnPathToOrigin_3D(2:end,1:3), return_types, return_sub_ids];
        
        finalDronePosition = startPoint_00_3D; 
        disp('---Regreso al inicio añadido---');
    else
        disp('--- No se requirió regreso al inicio.---');
    end
    
    if norm(fullPathWaypoints(end, 1:3) - finalDronePosition) > tolerance
        fullPathWaypoints = [fullPathWaypoints; finalDronePosition, PATH_TYPE_END, 0];
    else 
        fullPathWaypoints(end, 4) = PATH_TYPE_END;
        fullPathWaypoints(end, 5) = 0; 
    end
    
    valid_indices = [true; vecnorm(diff(fullPathWaypoints(:,1:3),1,1),2,2) > tolerance];
    fullPathWaypoints = fullPathWaypoints(valid_indices,:);
    fullPath = fullPathWaypoints;
end

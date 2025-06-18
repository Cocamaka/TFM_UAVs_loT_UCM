function distMatrix = calculateAStarDistanceMatrix(params)

    
    subregions_for_dist_calc = params.subregions;
    numActualSubregions = length(subregions_for_dist_calc);
    numNodes = numActualSubregions + 1; % +1 para el punto de inicio/fin virtual en (0,0)
    distMatrix = inf(numNodes, numNodes);
    startPoint_00_3D = [0, 0, params.drone.Altitude]; % Punto de inicio/fin virtual
    
    % Calcular la distancia desde el punto de inicio a cada subregión
    for i = 1:numActualSubregions
        current_subregion = subregions_for_dist_calc{i};
        targetEntryPoint = current_subregion.EntryPoint;
        
        % Calcular la ruta desde el punto de inicio al punto de entrada
        travelWaypoints_to_entry = findAStarPathBetweenPoints(startPoint_00_3D, targetEntryPoint, ...
                                            params.drone.Altitude, params.gridMap, params.gridResolution, ...
                                            params.mapOrigin, params.mapSize);
        distMatrix(1, i+1) = sum(vecnorm(diff(travelWaypoints_to_entry(:,1:3), 1, 1), 2, 2));
        
        % Si se requiere regresar al inicio, calcular la ruta desde el punto de salida al punto de inicio
        if params.drone.ReturnToHome
            sourceExitPoint_return = current_subregion.ExitPoint;
            travelWaypoints_from_exit = findAStarPathBetweenPoints(sourceExitPoint_return, startPoint_00_3D, ...
                                                 params.drone.Altitude, params.gridMap, params.gridResolution, ...
                                                 params.mapOrigin, params.mapSize);
            distMatrix(i+1, 1) = sum(vecnorm(diff(travelWaypoints_from_exit(:,1:3), 1, 1), 2, 2));
        else
            distMatrix(i+1, 1) = inf; 
        end
    end
    
    % Calcular la distancia entre subregiones
    for i = 1:numActualSubregions
        subregion_i = subregions_for_dist_calc{i};
        
        for j = 1:numActualSubregions
            if i == j
                distMatrix(i+1, j+1) = inf; 
                continue;
            end
            
            subregion_j = subregions_for_dist_calc{j};
            startExitPt_inter = subregion_i.ExitPoint;
            endEntryPt_inter = subregion_j.EntryPoint;
            
            travelWaypoints_inter = findAStarPathBetweenPoints(startExitPt_inter, endEntryPt_inter, ...
                                                 params.drone.Altitude, params.gridMap, params.gridResolution, ...
                                                 params.mapOrigin, params.mapSize);
            distMatrix(i+1, j+1) = sum(vecnorm(diff(travelWaypoints_inter(:,1:3), 1, 1), 2, 2));
        end
    end
    
    distMatrix(1,1) = inf; % Distancia del inicio a sí mismo
end

function waypoints_3d = findAStarPathBetweenPoints(startPt3D, endPt3D, altitude, gridMap, gridResolution, mapOrigin, mapSize)
    waypoints_3d = [];
    tolerance = 1e-6; 
    startGrid_initial = convertWorldToGridCoordinates(startPt3D(1:2), mapOrigin, gridResolution); 
    endGrid_initial = convertWorldToGridCoordinates(endPt3D(1:2), mapOrigin, gridResolution);   
    
    startRowClamped = max(1, min(startGrid_initial(1), mapSize(1)));
    startColClamped = max(1, min(startGrid_initial(2), mapSize(2)));
    startGrid = [startRowClamped, startColClamped];
    
    endRowClamped = max(1, min(endGrid_initial(1), mapSize(1)));
    endColClamped = max(1, min(endGrid_initial(2), mapSize(2)));
    endGrid = [endRowClamped, endColClamped];
    
    if isequal(startGrid, endGrid) || norm(startPt3D(1:2) - endPt3D(1:2)) < gridResolution
        if norm(startPt3D(1:2) - endPt3D(1:2)) > tolerance 
            worldPath2D_final = [startPt3D(1:2); endPt3D(1:2)];
        else
            worldPath2D_final = startPt3D(1:2); 
        end
        waypoints_3d = [worldPath2D_final, repmat(altitude, size(worldPath2D_final, 1), 1)];
        return;
    end
    
    % Ejecutar búsqueda A* para obtener la ruta de cuadrícula
    gridPathIndices = executeAStarSearchOnGrid(startGrid, endGrid, gridMap); 
    
    % Si A* no pudo encontrar una ruta
    if isempty(gridPathIndices)
        
        worldPath2D_final = [startPt3D(1:2); endPt3D(1:2)];
        waypoints_3d = [worldPath2D_final, repmat(altitude, size(worldPath2D_final, 1), 1)];
        return;
    end
    
    numGridPathPoints = size(gridPathIndices, 1);
    worldPath2D_raw = zeros(numGridPathPoints, 2);
    for i_pt = 1:numGridPathPoints
        worldPath2D_raw(i_pt,:) = convertGridToWorldCoordinates(gridPathIndices(i_pt,:), mapOrigin, gridResolution, mapSize); % Asumir que esta función existe
    end
    
    refinedPath2D = startPt3D(1:2); % Comenzar con el punto de inicio preciso
    if size(worldPath2D_raw,1) > 2 % Si la ruta A* tiene más de dos puntos (es decir, tiene puntos intermedios)
        refinedPath2D = [refinedPath2D; worldPath2D_raw(2:end-1,:)]; % Añadir puntos intermedios de A*
    elseif size(worldPath2D_raw,1) == 2 % Si A* solo devuelve dos puntos
        if ~isequal(worldPath2D_raw(1,:), startPt3D(1:2))
            refinedPath2D = [refinedPath2D; worldPath2D_raw(1,:)];
        end
        if ~isequal(worldPath2D_raw(2,:), endPt3D(1:2)) && ~isequal(worldPath2D_raw(2,:), refinedPath2D(end,:))
             refinedPath2D = [refinedPath2D; worldPath2D_raw(2,:)];
        end
    end
    if ~isequal(refinedPath2D(end,:), endPt3D(1:2)) % Asegurar que el punto final preciso se añada y no se duplique
        refinedPath2D = [refinedPath2D; endPt3D(1:2)]; 
    end
    
    % Eliminar puntos colineales de la ruta
    simplifiedPath2D = refinedPath2D;
    if size(refinedPath2D,1) > 2
        keep_indices = true(size(refinedPath2D, 1), 1);
        for pt_idx = 2:(size(refinedPath2D, 1) - 1)
            v1 = refinedPath2D(pt_idx,:) - refinedPath2D(pt_idx-1,:);
            v2 = refinedPath2D(pt_idx+1,:) - refinedPath2D(pt_idx,:);
            if norm(v1) > tolerance && norm(v2) > tolerance
                cosAngleVal = dot(v1/norm(v1), v2/norm(v2));
                if abs(abs(cosAngleVal) - 1) < tolerance * 10 % Relajar un poco la tolerancia para la colinealidad
                    keep_indices(pt_idx) = false;
                end
            elseif norm(v1) <= tolerance % El punto actual coincide con el anterior
                 keep_indices(pt_idx) = false;
            end
        end
        simplifiedPath2D = refinedPath2D(keep_indices,:);
    end
    
    if size(simplifiedPath2D, 1) > 2
        smoothedPathFinal = simplifiedPath2D(1,:); % La ruta suavizada comienza desde el primer punto
        currentSmoothedIdx_in_final = 1; % Apunta al punto actual en smoothedPathFinal
        originalPathIdx = 1; % Apunta al punto actual considerado en simplifiedPath2D
        
        while originalPathIdx < size(simplifiedPath2D, 1)
            furthestReachableOriginalIdx = originalPathIdx; % Inicializar al punto actual
            % Buscar hacia atrás desde el final de simplifiedPath2D, encontrar el punto más lejano
            % que pueda conectarse directamente con el último punto de smoothedPathFinal
            for j = size(simplifiedPath2D, 1):-1:(originalPathIdx + 1)
                if isLineOfSightClear(smoothedPathFinal(currentSmoothedIdx_in_final,:), simplifiedPath2D(j,:), gridMap, mapOrigin, gridResolution, mapSize)
                    furthestReachableOriginalIdx = j; % Se encontró un punto alcanzable directo más lejano
                    break; 
                end
            end
            
            if furthestReachableOriginalIdx > originalPathIdx 
                smoothedPathFinal = [smoothedPathFinal; simplifiedPath2D(furthestReachableOriginalIdx,:)];
                originalPathIdx = furthestReachableOriginalIdx; 
                currentSmoothedIdx_in_final = currentSmoothedIdx_in_final + 1;
            else
               
                if originalPathIdx + 1 <= size(simplifiedPath2D, 1)
                    smoothedPathFinal = [smoothedPathFinal; simplifiedPath2D(originalPathIdx + 1,:)];
                    originalPathIdx = originalPathIdx + 1;
                    currentSmoothedIdx_in_final = currentSmoothedIdx_in_final + 1;
                else
                    break; 
                end
            end
        end
        simplifiedPath2D = unique(smoothedPathFinal, 'rows', 'stable'); % Asegurar unicidad de nuevo
    end
  
    waypoints_3d = [simplifiedPath2D, repmat(altitude, size(simplifiedPath2D, 1), 1)];
    
    if size(waypoints_3d, 1) > 1
        valid_final_indices = [true; vecnorm(diff(waypoints_3d(:,1:3), 1, 1), 2, 2) > tolerance];
        waypoints_3d = waypoints_3d(valid_final_indices,:);
    end
end
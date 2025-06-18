function metrics = computePathPerformanceMetrics(params)
  
    fullPath = params.fullPath; % [x,y,z, tipo_punto_ruta, id_subregion]
    drone = params.drone;
    metrics = struct('TotalPathLength', 0, ...           % LTotal: Longitud total de la ruta
                'WorkingPathLength', 0, ...          % LTra: Longitud de la ruta de trabajo (pulverización en línea recta + ruta de giro dentro del trabajo)
                'TravelPathLength', 0, ...           % L_travel_inter_subregion_etc: Longitud de la ruta sin trabajo (transferencia entre subregiones, ida y vuelta a puntos de despegue/aterrizaje, etc.)
                'WorkingStraightPathLength', 0, ...     % Longitud de la ruta recta de trabajo
                'WorkingTurnPathLength', 0, ...      % Longitud de la ruta de giro dentro del trabajo
                'WorkingOperationTime', 0, ...          % TTra: Tiempo de trabajo (tiempo de pulverización en línea recta + tiempo de giro dentro del trabajo)
                'TravelOperationTime', 0, ...               % T_travel: Tiempo sin trabajo (tiempo de vuelo de la ruta de viaje + tiempo de giro en viaje)
                'TotalOperationTime', 0, ...                % TTotal: Tiempo total de operación
                'WorkingTurnCount', 0, ...              % NTra: Número de giros de trabajo
                'TravelTurnCount', 0, ...                % N_travel_turns: Número de giros de viaje
                'TotalTurnCount', 0, ...
                'EstimatedTravelDistanceACO', params.estimatedTravelDistance); % Distancia de viaje estimada por ACO

    PATH_TYPE_START = 1;
    PATH_TYPE_WORK = 2;          % Fin del segmento de trabajo en línea recta dentro de la subregión
    PATH_TYPE_TURN = 3;          % Fin del segmento de giro dentro de la subregión
    PATH_TYPE_TRAVEL = 4;        % Fin del segmento de transferencia entre subregiones o desde el inicio hasta la primera subregión
    PATH_TYPE_END = 5;           % Fin de toda la misión
    PATH_TYPE_RETURN = 6;        % Fin del segmento de regreso desde la última subregión al punto de despegue/aterrizaje
    
    droneSpeed = drone.Speed;
    timePerWorkTurn = drone.TimePerWorkTurn;     % Tiempo fijo por cada giro de trabajo
    timePerTravelTurn = drone.TimePerTravelTurn; % Tiempo fijo por cada giro de viaje

    if size(fullPath, 1) < 2
        disp('Advertencia: Puntos de ruta insuficientes, no se pueden calcular métricas de rendimiento detalladas.');
        if ~isnan(metrics.EstimatedTravelDistanceACO) && metrics.EstimatedTravelDistanceACO > 0
           
        end
        return;
    end
    for i = 1:(size(fullPath, 1) - 1)
        pt1_coords = fullPath(i, 1:3);
        pt2_coords = fullPath(i+1, 1:3);
        segmentLength = norm(pt2_coords - pt1_coords);
        
        metrics.TotalPathLength = metrics.TotalPathLength + segmentLength; 
        
        segment_start_type = fullPath(i, 4); 
        segment_end_type = fullPath(i+1, 4); 
        
        switch segment_end_type 
            case PATH_TYPE_WORK 
                metrics.WorkingStraightPathLength = metrics.WorkingStraightPathLength + segmentLength;
            case PATH_TYPE_TURN 
                metrics.WorkingTurnPathLength = metrics.WorkingTurnPathLength + segmentLength;
                metrics.WorkingTurnCount = metrics.WorkingTurnCount + 1;
            case {PATH_TYPE_TRAVEL, PATH_TYPE_RETURN} 
                metrics.TravelPathLength = metrics.TravelPathLength + segmentLength;
            case PATH_TYPE_END 
                if segment_start_type == PATH_TYPE_WORK
                    metrics.WorkingStraightPathLength = metrics.WorkingStraightPathLength + segmentLength;
                elseif segment_start_type == PATH_TYPE_TURN 
                    metrics.WorkingTurnPathLength = metrics.WorkingTurnPathLength + segmentLength;
                else 
                    metrics.TravelPathLength = metrics.TravelPathLength + segmentLength;
                end
            case PATH_TYPE_START
                metrics.TravelPathLength = metrics.TravelPathLength + segmentLength;
        end
    end
    
    metrics.WorkingPathLength = metrics.WorkingStraightPathLength + metrics.WorkingTurnPathLength;
    

    for i_node = 2:(size(fullPath, 1) - 1) % Iterar sobre nodos intermedios
        current_node_type = fullPath(i_node, 4);
        
      
        is_travel_related_node = (current_node_type == PATH_TYPE_TRAVEL || ...
                                  current_node_type == PATH_TYPE_RETURN || ...
                                  (current_node_type == PATH_TYPE_END && i_node < size(fullPath,1)-1) ); % Si es END pero no el último punto
                                  
        if is_travel_related_node
            pt_prev = fullPath(i_node-1, 1:2); % Coordenadas 2D para ángulo
            pt_curr = fullPath(i_node,   1:2);
            pt_next = fullPath(i_node+1, 1:2);
            
            vec1 = pt_curr - pt_prev; % Vector entrante
            vec2 = pt_next - pt_curr; % Vector saliente
            
            if norm(vec1) > 1e-6 && norm(vec2) > 1e-6
                cosAngle = dot(vec1, vec2) / (norm(vec1) * norm(vec2));
                if cosAngle < 0.99999 && cosAngle > -0.99999 % Tolerancia para colinealidad
                    metrics.TravelTurnCount = metrics.TravelTurnCount + 1;
                end
            end
        end
    end
    
    metrics.TotalTurnCount = metrics.WorkingTurnCount + metrics.TravelTurnCount;
    
    % Calcular tiempos
    working_straight_flight_time = metrics.WorkingStraightPathLength / droneSpeed;
    working_turns_fixed_time = metrics.WorkingTurnCount * timePerWorkTurn; % Tiempo fijo para giros de trabajo
    metrics.WorkingOperationTime = working_straight_flight_time + working_turns_fixed_time;
    
    travel_flight_time = metrics.TravelPathLength / droneSpeed;
    travel_turns_fixed_time = metrics.TravelTurnCount * timePerTravelTurn; % Tiempo fijo para giros de viaje
    metrics.TravelOperationTime = travel_flight_time + travel_turns_fixed_time;
    
    metrics.TotalOperationTime = metrics.WorkingOperationTime + metrics.TravelOperationTime;
end

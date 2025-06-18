function collides = isCollidingWithObstacles(plant_x, plant_y, obstacles)
    collides = false;
    if isempty(obstacles)
        return; 
    end

    for i = 1:numel(obstacles)
        obs = obstacles{i};
        
        if ~isfield(obs, 'Type') || ~isfield(obs, 'Position') || ~isfield(obs, 'L')
            continue;
        end

        obs_x_center = obs.Position(1);
        obs_y_center = obs.Position(2);
        
        switch obs.Type
            case 1 % Obstáculo Rectangular
                if ~isfield(obs, 'W')
                    continue;
                end
                obs_L = obs.L; % Longitud del obstáculo
                obs_W = obs.W; % Ancho del obstáculo
                
                % Límites del obstáculo (asumiendo que L es en X, W es en Y y no hay rotación)
                min_obs_x = obs_x_center - obs_L/2;
                max_obs_x = obs_x_center + obs_L/2;
                min_obs_y = obs_y_center - obs_W/2;
                max_obs_y = obs_y_center + obs_W/2;
                
                if (plant_x >= min_obs_x && plant_x <= max_obs_x && ...
                    plant_y >= min_obs_y && plant_y <= max_obs_y)
                    collides = true;
                    return; % Colisión detectada, no es necesario seguir verificando
                end
                
            case 2 % Obstáculo Circular
                obs_R = obs.L; % L es el radio para obstáculos circulares
                
                distance_sq = (plant_x - obs_x_center)^2 + (plant_y - obs_y_center)^2;
                if distance_sq <= obs_R^2
                    collides = true;
                    return; % Colisión detectada
                end
                
            otherwise
                % fprintf('Advertencia: Tipo de obstáculo %d desconocido para detección de colisión.\n', obs.Type);
        end
    end
end
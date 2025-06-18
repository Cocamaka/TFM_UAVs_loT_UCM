function planningObstacles = bufferObstaclesForPlanning(obstacles, horizontalSafetyDistance)
    planningObstacles = obstacles; 
    for i = 1:numel(obstacles)
        obs = obstacles{i}; 
        footprint_verts = obs.FootprintVertices; 
        
        % Calcular límites expandidos
        if ~isempty(footprint_verts) && size(footprint_verts, 1) >= 3 

            minX = min(footprint_verts(:,1)); 
            maxX = max(footprint_verts(:,1));
            minY = min(footprint_verts(:,2)); 
            maxY = max(footprint_verts(:,2));
            
            % Expandir límites
            minX_exp = minX - horizontalSafetyDistance; 
            maxX_exp = maxX + horizontalSafetyDistance;
            minY_exp = minY - horizontalSafetyDistance; 
            maxY_exp = maxY + horizontalSafetyDistance;
        else
            xc = obs.Position(1); 
            yc = obs.Position(2);
            obs_L = obs.L; 
            obs_W = obs.W; 

            % xpandir límites
            if obs.Type == 2 % Circular
                 minX_exp = xc - obs_L - horizontalSafetyDistance; 
                 maxX_exp = xc + obs_L + horizontalSafetyDistance;
                 minY_exp = yc - obs_L - horizontalSafetyDistance; 
                 maxY_exp = yc + obs_L + horizontalSafetyDistance;
            else % Rectangular
                 minX_exp = xc - obs_L/2 - horizontalSafetyDistance; 
                 maxX_exp = xc + obs_L/2 + horizontalSafetyDistance;
                 minY_exp = yc - obs_W/2 - horizontalSafetyDistance; 
                 maxY_exp = yc + obs_W/2 + horizontalSafetyDistance;
            end
        end
        

        planningObstacles{i}.ExpandedFootprint = [minX_exp minY_exp; maxX_exp minY_exp; 
                                                 maxX_exp maxY_exp; minX_exp maxY_exp];
        planningObstacles{i}.ExpandedBounds = [minX_exp maxX_exp minY_exp maxY_exp];
        planningObstacles{i}.ExpandedHeight = obs.H;
    end
    
    disp(['--- Los obstáculos se expanden según la distancia de seguridad horizontal (', num2str(horizontalSafetyDistance), 'm). ---']);
end
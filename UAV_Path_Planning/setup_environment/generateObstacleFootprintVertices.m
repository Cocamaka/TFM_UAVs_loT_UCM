function vertices = generateObstacleFootprintVertices(type, x_pos, y_pos, dim1, dim2)
    corners_relative_to_center = []; 
    
    switch type
        case 1 %Rectangular
            halfL = dim1 / 2; 
            halfW = dim2 / 2; 
            corners_relative_to_center = [-halfL, -halfW; 
                                          halfL, -halfW; 
                                          halfL, halfW; 
                                          -halfL, halfW];
        case 2 %Circular
            radius = dim1; 
            numPoints = 36; 
            theta_deg = linspace(0, 360, numPoints + 1)';
            theta_deg = theta_deg(1:end-1); 
            corners_relative_to_center = [radius * cosd(theta_deg), radius * sind(theta_deg)];
        otherwise
            disp(['Advertencia: generateObstacleFootprintVertices - Tipo de huella de obstáculo desconocido: ', num2str(type)]);
            vertices = [];
            return;
    end
    
    if ~isempty(corners_relative_to_center)
        vertices = corners_relative_to_center + [x_pos, y_pos];
    else
        vertices = [];
    end
end

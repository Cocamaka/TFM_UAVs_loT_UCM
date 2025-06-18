function renderPlants(ax, plants_data)
    coords = plants_data.Coordinates; % Coordenadas [X,Y] de las plantas
    height = plants_data.Height;     % Altura de las plantas
    diameter = plants_data.Diameter; % Diámetro del dosel
    numPlants = plants_data.Count;   % Número de plantas
    
    plantColor = [0.1, 0.65, 0.15]; % Verde oscuro para el dosel
    stemColor = [0.4, 0.7, 0.4];   % Verde más claro para los tallos
    markerSize_scatter = max(1, (diameter * 10)^2); 
    
    stemX_coords = [coords(:,1)'; coords(:,1)']; 
    stemY_coords = [coords(:,2)'; coords(:,2)']; 
    stemZ_coords = [zeros(1, numPlants); repmat(height, 1, numPlants)];
    plot3(ax, stemX_coords, stemY_coords, stemZ_coords, 'Color', stemColor, ...
          'LineWidth', 1.2, 'HandleVisibility', 'off');
    
    scatter3(ax, coords(:,1), coords(:,2), repmat(height, numPlants, 1), ... 
             markerSize_scatter, 'filled', 'MarkerFaceColor', plantColor, ...
             'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.75, 'HandleVisibility', 'off');
end

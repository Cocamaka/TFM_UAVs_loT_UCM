function plants = generatePlantDistribution(farmland, obstacles)
    defaultParams = {'200', '5', '5', '0.3', '0.5'}; 
    prompt = {'Número total objetivo de plantas:', 'Distancia entre hileras (Dirección Y, m):', 'Distancia entre plantas (Dirección X, m):', 'Diámetro del dosel de la planta (m):', 'Altura de la planta (m):'};
    answer = inputdlg(prompt, 'Definición de parámetros de la planta', [1 40], defaultParams);
    
    if isempty(answer)
        plants = struct(); 
        disp('--- El usuario canceló la definición de plantas.---'); 
        return; 
    end

    numPlantsTarget = max(0, round(str2double(answer{1})));
    rowSpacing = str2double(answer{2});
    plantSpacing = str2double(answer{3});
    diameter = str2double(answer{4});
    height = str2double(answer{5});

    if any(isnan([numPlantsTarget, rowSpacing, plantSpacing, diameter, height])) || ...
       any([rowSpacing, plantSpacing, diameter, height] <= 0)
        disp('--- Parámetros de planta inválidos, omitiendo la generación de plantas.---');
        plants = createEmptyPlantsStruct(numPlantsTarget, height, diameter, rowSpacing, plantSpacing);
        return;
    end
    

    coords = [];
    plantCount = 0;
    
    startX = farmland.XRange(1) + plantSpacing / 2; 
    startY = farmland.YRange(1) + rowSpacing / 2;   
    
    for y_coord = startY:rowSpacing:farmland.YRange(2)
        if plantCount >= numPlantsTarget, break; end
        
        for x_coord = startX:plantSpacing:farmland.XRange(2)
            if plantCount >= numPlantsTarget, break; end
            
            % Comprobar validez de la posición
            if ~inpolygon(x_coord, y_coord, farmland.Vertices(:,1), farmland.Vertices(:,2)) || ...
               isCollidingWithObstacles(x_coord, y_coord, obstacles) 
                continue; 
            end
            
            coords = [coords; x_coord, y_coord];
            plantCount = plantCount + 1;
        end
    end
    
    % Calcular estadísticas
    singlePlantArea = pi * (diameter / 2)^2;
    totalPlantingArea = plantCount * singlePlantArea;
    coverageRatio = (totalPlantingArea / farmland.Area) * 100;
    
    plants = struct(...
        'Coordinates', coords, ...
        'Height', height, ...
        'RowSpacing', rowSpacing, ...
        'PlantSpacing', plantSpacing, ...
        'Diameter', diameter, ...
        'Count', plantCount, ...
        'TargetCount', numPlantsTarget, ...
        'PlantingArea', totalPlantingArea, ...
        'CoverageRatio', coverageRatio ...
    );
    
    disp(['--- Se han generado ', num2str(plantCount), ' plantas. ---']);
end

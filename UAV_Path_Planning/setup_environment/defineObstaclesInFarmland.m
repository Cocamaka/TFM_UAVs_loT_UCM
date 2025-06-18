function obstacles = defineObstaclesInFarmland(farmland)
    numObsStr = inputdlg('Ingrese el número de obstáculos (0-3):', 'Definición del número de obstáculos', [1 45], {'1'});
    if isempty(numObsStr)
        obstacles = {}; 
        disp('--- Cancelada la definición de obstáculos. ---'); 
        return; 
    end
    
    numObs = max(0, round(str2double(numObsStr{1})));
    if isnan(numObs), numObs = 0; end
    
    if numObs == 0
        obstacles = {};
        disp('--- No se definieron obstáculos. ---');
        return;
    end
    
    obstacles = cell(1, numObs);
    shapeDialogStrings = {'1=Rectangular', '2=Circular'};
    user_defined_fixed_centers = {[20, 20], [65, 40], [50, 55]};
    
    for i = 1:numObs
        prompt_all = {
            sprintf('Obstáculo %d - Forma (%s):', i, strjoin(shapeDialogStrings, ', '));
            'Dimensión 1 (Rectángulo: Largo / Círculo: Radio) (m):';
            'Dimensión 2 (Rectángulo: Ancho, m):'; 
            'Altura (m):';
            'Coordenada X del centro (m):';
            'Coordenada Y del centro (m):'
        };
        
        if i <= length(user_defined_fixed_centers)
            default_x = num2str(user_defined_fixed_centers{i}(1), '%.2f');
            default_y = num2str(user_defined_fixed_centers{i}(2), '%.2f');
        else
            default_x = num2str(farmland.XRange(1) + farmland.Length / (numObs + 1) * i, '%.2f');
            default_y = num2str(farmland.YRange(1) + farmland.Width / 2, '%.2f');
        end
        
        defaultAns = {'1', '10', '10', '15', default_x, default_y};
        answer = inputdlg(prompt_all, sprintf('Definición de parámetros del obstáculo %d/%d', i, numObs), [1 70], defaultAns);
        
        if isempty(answer)
            disp(['--- Cancelada la definición del obstáculo ', num2str(i), '.---']); 
            continue; 
        end

        type_val = max(1, min(2, round(str2double(answer{1}))));
        dim1_val = str2double(answer{2}); 
        dim2_val = str2double(answer{3}); 
        height = str2double(answer{4}); 
        x_center = str2double(answer{5});
        y_center = str2double(answer{6});
        
        if any(isnan([type_val, dim1_val, height, x_center, y_center])) || dim1_val <= 0 || height <= 0
            disp(['--- Parámetros de entrada inválidos para el obstáculo ', num2str(i), ', omitiendo este obstáculo. ---']);
            continue;
        end
        % Procesar parámetros de forma
        if type_val == 1 % Rectangular
            if isnan(dim2_val) || dim2_val <= 0
                disp(['--- Ancho inválido para el obstáculo rectangular ', num2str(i), ', omitiendo este obstáculo. ---']);
                continue;
            end
            width = dim2_val;
            shapeName = 'Rectangular';
            is_circular = false;
        else % Circular
            width = NaN;
            shapeName = 'Circular';
            is_circular = true;
        end
        
        % Generar huella del obstáculo
        preciseFootprint = generateObstacleFootprintVertices(type_val, x_center, y_center, dim1_val, width);
        
        % Establecer huella de planificación
        if is_circular
            half_side = dim1_val; % Radio
            planningFootprint = [
                x_center - half_side, y_center - half_side;
                x_center + half_side, y_center - half_side;
                x_center + half_side, y_center + half_side;
                x_center - half_side, y_center + half_side
            ];
        else
            planningFootprint = preciseFootprint;
        end
        
        if isempty(preciseFootprint) || isempty(planningFootprint)
            disp(['--- No se pudo generar una huella válida para el obstáculo ', num2str(i), ', omitiendo.']);
            continue;
        end

        obstacles{i} = struct(...
            'Type', type_val, ...
            'ShapeName', shapeName, ...
            'L', dim1_val, ...
            'W', width, ...
            'H', height, ...
            'Position', [x_center, y_center, height/2], ...
            'Rotation', 0, ...
            'Volume', NaN, ...
            'FootprintVertices', preciseFootprint, ...
            'PlanningFootprintVertices', planningFootprint ...
        );
    end 
    
    obstacles = obstacles(~cellfun('isempty', obstacles)); 
    
    if ~isempty(obstacles)
        disp(['--- Se han generado ', num2str(length(obstacles)), ' obstáculos válidos. ---']);
    else
        disp('--- No se definieron o no se generaron obstáculos válidos. ---');
    end
end

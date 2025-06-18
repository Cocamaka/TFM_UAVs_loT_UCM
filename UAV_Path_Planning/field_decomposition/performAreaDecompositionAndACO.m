function params = performAreaDecompositionAndACO(params) 
    
    original_subregions = decomposeFieldWithBoustrophedon(...
        params.farmland, params.obstacles, params.drone.Width, params.drone.HorizontalSafetyDistance);
    
    fprintf('--- Descomposición Boustrophedon mejorada completada: Se generaron %d subregiones.\n', length(original_subregions));
            
    params.subregions = original_subregions; 
    
    if isempty(params.subregions)
        disp('--- No se generaron subregiones, omitiendo la ordenación de ruta ACO. ---');
        params.optimalSequence = [];
        params.estimatedTravelDistance = 0;
        params.aco = struct(); 
        fprintf('\n--- Parte 2 completada ---\n');
        return; 
    end
    disp(['--- Número de subregiones (no optimizado): ', num2str(length(params.subregions)), '.']);
    
    if ~isempty(params.subregions) 
        for k = 1:length(params.subregions)
            current_verts = params.subregions{k}.Vertices;
            current_angle_for_coverage = params.subregions{k}.OptimalSweepAngle; 
            [~, entry_pt, exit_pt] = generateBoustrophedonCoverageForSubregion(...
                current_verts, params.drone.Width, params.drone.Altitude, current_angle_for_coverage);
            params.subregions{k}.EntryPoint = entry_pt; 
            params.subregions{k}.ExitPoint = exit_pt;   
        end
    end
    
    numValidSubregionsForACO = 0;
    if ~isempty(params.subregions)
        valid_indices = false(1, length(params.subregions));
        for i = 1:length(params.subregions)
            if isfield(params.subregions{i}, 'EntryPoint') && ~isempty(params.subregions{i}.EntryPoint) && ~any(isnan(params.subregions{i}.EntryPoint(:))) && ...
               isfield(params.subregions{i}, 'ExitPoint') && ~isempty(params.subregions{i}.ExitPoint) && ~any(isnan(params.subregions{i}.ExitPoint(:)))
                valid_indices(i) = true;
            else
                fprintf('Advertencia: La subregión %d (ID: %d) carece de puntos de entrada/salida válidos, se excluirá de ACO.\n', i, params.subregions{i}.ID);
            end
        end
        params.subregionsForACO = params.subregions(valid_indices);
        numValidSubregionsForACO = length(params.subregionsForACO);
        fprintf('--- Número de subregiones válidas optimizadas: %d\n', numValidSubregionsForACO);
    else
        params.subregionsForACO = {}; 
    end
    
    if numValidSubregionsForACO >= 1 
        % El parámetro Q ha sido eliminado de la entrada del usuario
        prompt_aco = {'Número de hormigas (NumAnts):', 'Número máximo de iteraciones (NumIterations):', ...
                      'Importancia de la feromona (Alpha):', 'Importancia de la información heurística (Beta):', ...
                      'Tasa de evaporación de la feromona (EvaporationRate):'};
        dlgtitle_aco = 'Configuración de parámetros del algoritmo de colonia de hormigas (ACO)';
        dims_aco = [1 60]; 
        defaultAns_aco = {'100', '100', '0.5', '1.5', '0.5'}; 
        answer_aco = inputdlg(prompt_aco, dlgtitle_aco, dims_aco, defaultAns_aco);
        
        acoParams = struct();
        acoParams.numAnts = round(str2double(answer_aco{1}));
        acoParams.numIterations = round(str2double(answer_aco{2}));
        acoParams.alpha = str2double(answer_aco{3});
        acoParams.beta = str2double(answer_aco{4});
        acoParams.evaporationRate = str2double(answer_aco{5});
        params.aco = acoParams; 
        
        tempParamsForDistMat = params; 
        tempParamsForDistMat.subregions = params.subregionsForACO; 
        
        if isempty(tempParamsForDistMat.subregions) && numValidSubregionsForACO > 0
             disp('Error: subregionsForACO está vacío, pero numValidSubregionsForACO > 0. Revise la lógica de filtrado.');
             params.optimalSequence = []; params.estimatedTravelDistance = NaN;
             return;
        elseif isempty(tempParamsForDistMat.subregions) && numValidSubregionsForACO == 0
            distMatrixACO = []; 
        else
            distMatrixACO = calculateAStarDistanceMatrix(tempParamsForDistMat);
        end
        
        if isempty(distMatrixACO) && numValidSubregionsForACO > 0
            disp('Error: La matriz de distancias está vacía, pero existen subregiones válidas. No se puede ejecutar ACO.');
            params.optimalSequence = find(valid_indices); 
            params.estimatedTravelDistance = NaN;
        elseif isempty(distMatrixACO) && numValidSubregionsForACO == 0
             params.optimalSequence = [];
             params.estimatedTravelDistance = 0;
        else
            [optimalSequence_aco, bestTourLength] = executeACOForSubregionSequence(...
                distMatrixACO, params.aco, params.drone.ReturnToHome);
            
            originalIndices = find(valid_indices); 
            if ~isempty(optimalSequence_aco) && all(optimalSequence_aco > 0) && all(optimalSequence_aco <= length(originalIndices))
                params.optimalSequence = originalIndices(optimalSequence_aco);
            else
                params.optimalSequence = originalIndices; 
                bestTourLength = NaN; 
                disp('--- ACO no devolvió una secuencia de recorrido válida o la secuencia es inválida, se procesarán las subregiones válidas en orden original.---');
            end
            if ~isempty(params.optimalSequence) && ~isnan(bestTourLength)
                disp('--- Algoritmo ACO completado ---');
                valid_optimal_sequence_for_display = params.optimalSequence(arrayfun(@(x) isfield(params.subregions{x}, 'ID'), params.optimalSequence));
                if ~isempty(valid_optimal_sequence_for_display)
                     fprintf('--- Secuencia óptima de ID de subregión: %s\n', ...
                             num2str(cellfun(@(c) c.ID, params.subregions(valid_optimal_sequence_for_display)'))); 
                else
                     fprintf('--- Secuencia óptima de ID de subregión (desde 0,0): No se puede mostrar (falta el campo ID o problema de secuencia)\n');
                end
                fprintf('--- Distancia total de viaje estimada por ACO: %.2f m\n', bestTourLength);
            elseif isempty(params.optimalSequence) && numValidSubregionsForACO > 0
                 disp('--- ACO no devolvió una secuencia de recorrido válida, pero existen subregiones válidas, se procesarán en orden original.---');
                 params.optimalSequence = originalIndices; 
                 params.estimatedTravelDistance = NaN; 
            end
            params.estimatedTravelDistance = bestTourLength;
        end
        
    elseif numValidSubregionsForACO == 1 
        originalIndex = find(valid_indices);
        params.optimalSequence = originalIndex; 
        disp('--- Solo hay una subregión válida, se accederá directamente desde (0,0).---');
        startPoint = [0, 0, params.drone.Altitude];
        if ~isempty(params.subregionsForACO) && isfield(params.subregionsForACO{1}, 'EntryPoint') && ~isempty(params.subregionsForACO{1}.EntryPoint)
            entryPoint = params.subregionsForACO{1}.EntryPoint;
            path_to_subregion = findAStarPathBetweenPoints(startPoint, entryPoint, ...
                params.drone.Altitude, params.gridMap, params.gridResolution, ...
                params.mapOrigin, params.mapSize);
            distance = sum(vecnorm(diff(path_to_subregion(:,1:3),1,1),2,2));
            if params.drone.ReturnToHome
                 if isfield(params.subregionsForACO{1}, 'ExitPoint') && ~isempty(params.subregionsForACO{1}.ExitPoint)
                    exitPoint = params.subregionsForACO{1}.ExitPoint;
                    path_from_subregion = findAStarPathBetweenPoints(exitPoint, startPoint, ...
                        params.drone.Altitude, params.gridMap, params.gridResolution, ...
                        params.mapOrigin, params.mapSize);
                    distance = distance + sum(vecnorm(diff(path_from_subregion(:,1:3),1,1),2,2));
                 else
                    disp('Advertencia: La subregión única carece de un punto de salida válido, no se puede calcular la distancia de regreso.');
                    distance = NaN; 
                 end
            end
            params.estimatedTravelDistance = distance;
            fprintf('--- Distancia de viaje estimada a la subregión única: %.2f m\n', params.estimatedTravelDistance);
        else
            disp('Error: La subregión válida única carece de información del punto de entrada.');
            params.optimalSequence = [];
            params.estimatedTravelDistance = NaN;
        end
    else 
        params.optimalSequence = [];
        params.estimatedTravelDistance = 0;
        params.aco = struct(); 
        disp('--- No hay subregiones válidas que requieran planificación de ruta ACO. ---');
    end
    
    fprintf('\n--- Parte 2 (Descomposición del área y ordenación de ruta ACO) completada ---\n');
end

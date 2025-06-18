function displaySubregionTraversalInfo(params)
    % Mostrar información del orden de recorrido de subregiones y puntos de entrada/salida reales
    disp(repmat('=', 1, 100));
    disp('                               Orden de recorrido de subregiones y puntos de entrada/salida reales (extraídos de la ruta completa)');
    disp(repmat('-', 1, 100));
    
    % Obtener parámetros principales
    subregions_all = params.subregions; 
    optimal_sequence_indices = params.optimalSequence; 
    full_path_data = params.fullPath; % [x,y,z, tipo, id_subregion]
    numSubregionsTotal = length(subregions_all);
    
    % Imprimir número de subregiones
    fprintf('  Número total de subregiones (filtradas): %d\n', numSubregionsTotal);
    
    % Construir cadena de secuencia de recorrido
    seqStrParts = cell(1, length(optimal_sequence_indices));
    for i = 1:length(optimal_sequence_indices) 
        seqIdx = optimal_sequence_indices(i);
        seqStrParts{i} = sprintf('S%d', subregions_all{seqIdx}.ID); 
    end
    
    % Imprimir orden de recorrido del dron
    fprintf('  Orden de recorrido del dron: Inicio(0,0) -> %s', strjoin(seqStrParts, ' -> '));
    if params.drone.ReturnToHome
        fprintf(' -> Fin(0,0)'); 
    end 
    fprintf('\n');
    disp(repmat('-', 1, 100));
    
    % Preparar datos de la tabla
    numInSequenceToDisplay = length(optimal_sequence_indices);
    optimal_sequence_indices_display = optimal_sequence_indices;
    
    % Inicializar columnas de la tabla
    Order_Col = cell(numInSequenceToDisplay, 1);
    SubregionID_Col = cell(numInSequenceToDisplay, 1);
    PreCalcEntry_Col = cell(numInSequenceToDisplay, 1);
    PreCalcExit_Col = cell(numInSequenceToDisplay, 1);
    ActualEntry_Col = cell(numInSequenceToDisplay, 1);
    ActualExit_Col = cell(numInSequenceToDisplay, 1);
    
    % Rellenar datos de la tabla
    for i_row = 1:numInSequenceToDisplay 
        % Obtener información de la subregión actual
        current_sub_idx_in_all = optimal_sequence_indices_display(i_row);
        sub_struct = subregions_all{current_sub_idx_in_all}; 
        actualSubregionID = sub_struct.ID; 
        
        % Información básica
        Order_Col{i_row} = sprintf('%d', i_row);
        SubregionID_Col{i_row} = sprintf('S%d', actualSubregionID);
        
        % Puntos de entrada y salida precalculados
        PreCalcEntry_Col{i_row} = sprintf('(%.1f,%.1f,%.1f)', ...
                                    sub_struct.EntryPoint(1), ...
                                    sub_struct.EntryPoint(2), ...
                                    sub_struct.EntryPoint(3));
        PreCalcExit_Col{i_row} = sprintf('(%.1f,%.1f,%.1f)', ...
                                   sub_struct.ExitPoint(1), ...
                                   sub_struct.ExitPoint(2), ...
                                   sub_struct.ExitPoint(3));
        
        % Extraer puntos de entrada y salida reales de full_path_data
        entryPt_actual = []; 
        exitPt_actual = [];
        
        % Encontrar índices en full_path_data correspondientes a la subregión actual
        subregionPathIndices_in_full = find(full_path_data(:, 5) == actualSubregionID); % Columna 5 es ID de subregión
        
        if ~isempty(subregionPathIndices_in_full)
            % Intentar encontrar el primer punto de TRABAJO (tipo 2) como punto de entrada
            firstWorkPointIdx = find(full_path_data(subregionPathIndices_in_full, 4) == 2, 1, 'first'); % Columna 4 es tipo
            if ~isempty(firstWorkPointIdx)
                entryPt_actual = full_path_data(subregionPathIndices_in_full(firstWorkPointIdx), 1:3);
            else 
                % Si no hay puntos de trabajo, usar el primer punto de la subregión en la ruta
                entryPt_actual = full_path_data(subregionPathIndices_in_full(1), 1:3); 
            end
            
            % Intentar encontrar el último punto de TRABAJO (tipo 2) como punto de salida
            lastWorkPointIdx = find(full_path_data(subregionPathIndices_in_full, 4) == 2, 1, 'last');
            if ~isempty(lastWorkPointIdx)
                exitPt_actual = full_path_data(subregionPathIndices_in_full(lastWorkPointIdx), 1:3);
            else 
                % Si no hay puntos de trabajo, usar el último punto de la subregión en la ruta
                exitPt_actual = full_path_data(subregionPathIndices_in_full(end), 1:3); 
            end
        end
        
        % Formatear punto de entrada real
        if ~isempty(entryPt_actual)
            ActualEntry_Col{i_row} = sprintf('(%.1f,%.1f,%.1f)', ...
                                      entryPt_actual(1), ...
                                      entryPt_actual(2), ...
                                      entryPt_actual(3));
        else
            ActualEntry_Col{i_row} = 'No extraído'; 
        end
        
        % Formatear punto de salida real
        if ~isempty(exitPt_actual)
            ActualExit_Col{i_row} = sprintf('(%.1f,%.1f,%.1f)', ...
                                     exitPt_actual(1), ...
                                     exitPt_actual(2), ...
                                     exitPt_actual(3));
        else
            ActualExit_Col{i_row} = 'No extraído'; 
        end
    end
    
    % Crear y mostrar tabla
    T = table(Order_Col, SubregionID_Col, PreCalcEntry_Col, PreCalcExit_Col, ...
              ActualEntry_Col, ActualExit_Col, 'VariableNames', ...
              {'Orden', 'ID Subregión', 'Entrada Precalculada', 'Salida Precalculada', 'Punto de Entrada Real', 'Punto de Salida Real'});
    disp(T);
    disp(repmat('=', 1, 100));
end
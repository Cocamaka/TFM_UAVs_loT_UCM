function displayPathMetricsSummary(metrics)
    disp(repmat('=', 1, 70));
    disp('                             Resultados de la Planificación de Ruta');
    disp(repmat('-', 1, 70));
    
    MetricDisplayNames = {'Longitud de Ruta de Trabajo (m)';         % Corresponde a WorkingPathLength
                         'Distancia Total de Vuelo (m)';           % Corresponde a TotalPathLength
                         'Distancia Total Sin Trabajo (m)';         % Corresponde a TravelPathLength
                         'Distancia TSP Estimada por ACO (m)'; 
                         'Tiempo de Trabajo (min)'; 
                         'Tiempo Total de Operación (min)'; 
                         'Número de Giros de Trabajo'; 
                         'Número de Giros de Viaje'; 
                         'Número Total de Giros'};
    
    MetricFieldNames = {'WorkingPathLength';          % Original WorkingDistance
                       'TotalPathLength';                        % Original TotalDistance
                       'TravelPathLength';                  % Original TravelDistance
                       'EstimatedTravelDistanceACO'; 
                       'WorkingOperationTime'; 
                       'TotalOperationTime'; 
                       'WorkingTurnCount'; 
                       'TravelTurnCount'; 
                       'TotalTurnCount'};
    
    FormattedValues = cell(length(MetricDisplayNames), 1);
    for i = 1:length(MetricDisplayNames)
        fieldName = MetricFieldNames{i}; 
        if isfield(metrics, fieldName) 
            val = metrics.(fieldName); 
        
            % Formatear según el tipo de métrica
            if contains(fieldName, 'Time') 
                FormattedValues{i} = sprintf('%.2f', val / 60); 
            elseif contains(fieldName, 'Distance') || contains(fieldName, 'Length') 
                FormattedValues{i} = sprintf('%.2f', val);
            elseif contains(fieldName, 'Count') 
                FormattedValues{i} = sprintf('%d', val);
            else
                FormattedValues{i} = num2str(val); 
            end
        else
            FormattedValues{i} = 'N/D'; 
            warning('Advertencia: No se encontró el campo %s en la estructura metrics', fieldName);
        end
    end
    
    % Crear y mostrar tabla
    T_metrics = table(MetricDisplayNames, FormattedValues, 'VariableNames', {'Métrica', 'Valor'});
    disp(T_metrics);
    disp(repmat('=', 1, 70));
end
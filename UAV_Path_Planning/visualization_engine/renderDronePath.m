function renderDronePath(ax, fullPath)

pathCoords = fullPath(:, 1:3); % Coordenadas X, Y, Z
    pathTypes = fullPath(:, 4);    % Tipo de cada punto de ruta (el tipo del punto final del segmento define el segmento)
    
    colorWork = [0, 0, 1];           % Color de la ruta de trabajo (azul)
    colorNonWork = [1, 0.7, 0];      % Color de la ruta sin trabajo (amarillo anaranjado)
    colorStart = [0, 0.8, 0];        % Color del punto de inicio (verde)
    colorEnd = [1, 0, 0];            % Color del punto final (rojo)
    colorDefault = [0.5, 0.5, 0.5];  % Color predeterminado (gris)
    
    styleWork = '-';                 % Estilo de la ruta de trabajo (línea continua)
    widthWork = 2.5;                 % Ancho de la ruta de trabajo
    styleNonWork = '--';             % Estilo de la ruta sin trabajo (línea discontinua)
    widthNonWork = 2.0;              % Ancho de la ruta sin trabajo
    
    % Dibujar segmentos de la ruta
    for i = 1:(size(pathCoords, 1) - 1)
        startSeg_coords = pathCoords(i, :);   % Coordenadas del inicio del segmento
        endSeg_coords = pathCoords(i+1, :); % Coordenadas del fin del segmento
        segment_end_type = pathTypes(i+1);    % El tipo del punto final del segmento define el segmento
        
        lineColor_seg = colorDefault;
        lineStyle_seg = ':'; 
        lineWidth_seg = 1.0;
        
        % Establecer propiedades de la línea según el tipo de ruta
        switch segment_end_type
            case 2      % Ruta de trabajo (WORK)
                lineColor_seg = colorWork;
                lineStyle_seg = styleWork;
                lineWidth_seg = widthWork;
            case {3, 4, 6}  % Tipos de ruta sin trabajo (TURN, TRAVEL, RETURN)
                lineColor_seg = colorNonWork;
                lineStyle_seg = styleNonWork;
                lineWidth_seg = widthNonWork;
            case 5   % Punto final de la misión (END), el segmento que lleva a él
                segment_start_type = pathTypes(i); % Comprobar el tipo del punto de inicio del segmento
                if segment_start_type == 2 % Si venía de un punto de trabajo
                    lineColor_seg = colorWork;
                    lineStyle_seg = styleWork;
                    lineWidth_seg = widthWork;
                else    % Si venía de un giro, viaje, etc.
                    lineColor_seg = colorNonWork;
                    lineStyle_seg = styleNonWork;
                    lineWidth_seg = widthNonWork;
                end
            case 1  % Punto de inicio (START), el segmento que sale de él
                lineColor_seg = colorNonWork; % El primer segmento desde el inicio es de viaje
                lineStyle_seg = styleNonWork;
                lineWidth_seg = widthNonWork;
        end
        
        % Dibujar el segmento de la línea de ruta
        plot3(ax, [startSeg_coords(1), endSeg_coords(1)], ...
                  [startSeg_coords(2), endSeg_coords(2)], ...
                  [startSeg_coords(3), endSeg_coords(3)], ...
                  'Color', lineColor_seg, 'LineWidth', lineWidth_seg, ...
                  'LineStyle', lineStyle_seg, 'HandleVisibility', 'off');
    end
    
    startIdx_path = find(pathTypes == 1, 1, 'first'); % Encontrar el primer punto de tipo START
    if ~isempty(startIdx_path)
        startPt_coords = pathCoords(startIdx_path, :);
        plot3(ax, startPt_coords(1), startPt_coords(2), startPt_coords(3), 'o', ... % Círculo
              'MarkerSize', 10, 'MarkerFaceColor', colorStart, 'MarkerEdgeColor', 'k', ...
              'LineWidth', 1.5, 'HandleVisibility', 'off');
        text(ax, startPt_coords(1), startPt_coords(2), startPt_coords(3) + 1.5, ' Inicio', ...
             'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
             'HandleVisibility', 'off');
    end
    
    % Marcar el punto final
    endIdx_path = find(pathTypes == 5, 1, 'last'); % Encontrar el último punto de tipo END
    end_label_text = ' Fin'; % Texto predeterminado para la etiqueta del fin
    
    if isempty(endIdx_path) && size(pathCoords, 1) >= 1 % Si no hay tipo END, marcar el último punto
        endIdx_path = size(pathCoords, 1);
        end_label_text = ' Fin (final de ruta)';
    end
    
    if ~isempty(endIdx_path)
        endPt_coords = pathCoords(endIdx_path, :);
        plot3(ax, endPt_coords(1), endPt_coords(2), endPt_coords(3), 's', ... % Cuadrado
              'MarkerSize', 10, 'MarkerFaceColor', colorEnd, 'MarkerEdgeColor', 'k', ...
              'LineWidth', 1.5, 'HandleVisibility', 'off');
        
        % Modificar etiqueta si el fin es en (0,0)
        if norm(endPt_coords(1:2)) < 1e-3 && pathTypes(endIdx_path) == 5 % Si está cerca del origen y es tipo END
            end_label_text = ' Fin (regreso al inicio)';
        end
        
        text(ax, endPt_coords(1), endPt_coords(2), endPt_coords(3) + 1.5, end_label_text, ...
             'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
             'HandleVisibility', 'off');
    end
end

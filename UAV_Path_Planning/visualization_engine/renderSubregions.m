function renderSubregions(ax, subregions_list)
    subregionEdgeColor = [0.5, 0, 0.5]; % Morado para el borde
    subregionFillColor = [0.8, 0.6, 0.8]; % Morado claro para el relleno
    textColor = [0.3, 0, 0.3];        % Color del texto de la etiqueta
    
    for i = 1:length(subregions_list)
        sub = subregions_list{i};
        verts = sub.Vertices; % Vértices de la subregión
        
        % Dibujar la base de la subregión (relleno)
        patch(ax, 'XData', verts(:,1), 'YData', verts(:,2), ...
              'ZData', zeros(size(verts,1),1) + 0.02, 'FaceColor', subregionFillColor, ... % Ligeramente por encima del suelo
              'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        
        % Dibujar el contorno de la subregión
        plot3(ax, [verts(:,1); verts(1,1)], [verts(:,2); verts(1,2)], ... % Cerrar el polígono
              zeros(size(verts,1)+1, 1) + 0.03, '--', 'Color', subregionEdgeColor, ... % Ligeramente por encima del relleno
              'LineWidth', 1.5, 'HandleVisibility', 'off');
        
        % Añadir etiqueta de ID de la subregión en su centroide
        text(ax, sub.Centroid(1), sub.Centroid(2), 0.1, sprintf('S%d', sub.ID), ...
             'Color', textColor, 'FontSize', 10, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
             'BackgroundColor', [1,1,1,0.6], 'HandleVisibility', 'off'); % Fondo semitransparente
    end
end

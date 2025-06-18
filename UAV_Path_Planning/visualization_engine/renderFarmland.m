function renderFarmland(ax, farmland)

patch(ax, 'XData', farmland.Vertices(:,1), 'YData', farmland.Vertices(:,2), ...
          'ZData', zeros(size(farmland.Vertices,1),1), 'FaceColor', [0.7,0.9,0.7], ...
          'FaceAlpha', 0.4, 'EdgeColor', [0.1,0.4,0.1], 'LineWidth', 1.5, ...
          'HandleVisibility', 'off');
    
    plot3(ax, [farmland.Vertices(:,1); farmland.Vertices(1,1)], ... 
          [farmland.Vertices(:,2); farmland.Vertices(1,2)], ...
          zeros(size(farmland.Vertices,1)+1,1) + 0.01, 'Color', [0,0.2,0], ... 
          'LineWidth', 2.0, 'HandleVisibility', 'off');
    
    gridSpacing = 10; 
    xGrid = floor(farmland.XRange(1)/gridSpacing)*gridSpacing : gridSpacing : ceil(farmland.XRange(2)/gridSpacing)*gridSpacing;
    yGrid = floor(farmland.YRange(1)/gridSpacing)*gridSpacing : gridSpacing : ceil(farmland.YRange(2)/gridSpacing)*gridSpacing;
    
    for xVal = xGrid
        plot3(ax, [xVal xVal], farmland.YRange, [0 0], '--', ... 
              'Color', [0.85,0.85,0.85], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    end
    
    for yVal = yGrid
        plot3(ax, farmland.XRange, [yVal yVal], [0 0], '--', ...
              'Color', [0.85,0.85,0.85], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    end
    
    plot3(ax, 0, 0, 0, 'kp', 'MarkerFaceColor', 'k', 'MarkerSize', 8, 'HandleVisibility', 'off'); 
    text(ax, 1, -1, 0.1, '(0,0)', 'Color', 'k', 'FontSize', 9, 'HandleVisibility', 'off');
end
function [gridMap, gridResolution, mapOrigin, mapSize] = createOccupancyGridMap(farmland, obstacles, horizontalSafetyDistance)
    disp('--- Mapa de cuadrícula para planificación de ruta A* ---');
    
    minRes = 0.1; 
 %Resolución mínima
    
    desiredRes = 0.5;
    %Tamaño de celda deseado, valores más pequeños mejoran la precisión de la ruta pero aumentan el tiempo de cálculo.
                    
    gridResolution = max(minRes, desiredRes); 
    
    
    mapOrigin = [farmland.XRange(1), farmland.YRange(1)]; 
    cols = ceil((farmland.XRange(2) - mapOrigin(1)) / gridResolution);
    rows = ceil((farmland.YRange(2) - mapOrigin(2)) / gridResolution);
    mapSize = [rows, cols]; 
    
    fprintf('    Resolución de cuadrícula: %.2f m, Tamaño del mapa (filas×columnas): %d × %d\n', gridResolution, rows, cols);
    
    gridMap = false(rows, cols); 
    
    xCenters = mapOrigin(1) + ((1:cols) - 0.5) * gridResolution;
    yCenters = mapOrigin(2) + ((1:rows) - 0.5) * gridResolution;
    [X_centers_mesh, Y_centers_mesh] = meshgrid(xCenters, yCenters);
    cell_centers = [X_centers_mesh(:), Y_centers_mesh(:)]; 
    
    hasReorient = exist('reorientboundaries', 'file') == 2; 
    hasSimplify = exist('simplify', 'file') == 2;       
    
    planning_obstacle_polys = cell(1, numel(obstacles));
    for i_obs = 1:numel(obstacles)
        if isfield(obstacles{i_obs}, 'PlanningFootprintVertices') && ~isempty(obstacles{i_obs}.PlanningFootprintVertices)
            planning_obstacle_polys{i_obs} = polyshape(obstacles{i_obs}.PlanningFootprintVertices);
        else
            planning_obstacle_polys{i_obs} = polyshape(); 
        end
    end
    
    bufferedObstaclesForPlanning = createBufferedObstaclePolygons(planning_obstacle_polys, horizontalSafetyDistance,... 
                                                       hasReorient, hasSimplify);
    
    obstacle_mask = false(size(cell_centers,1), 1); 
    for i = 1:numel(bufferedObstaclesForPlanning) 
        poly_to_check = bufferedObstaclesForPlanning{i};
        if ~isempty(poly_to_check.Vertices) 
            in_obstacle = isinterior(poly_to_check, cell_centers(:,1), cell_centers(:,2));
            obstacle_mask = obstacle_mask | in_obstacle; 
        end
    end
    
    if any(obstacle_mask) 
        gridMap = reshape(obstacle_mask, rows, cols);
    end
    
    disp('--- Mapa de cuadrícula completado. ---');
end
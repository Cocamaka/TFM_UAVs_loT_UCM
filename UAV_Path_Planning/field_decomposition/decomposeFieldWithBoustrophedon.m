function subregions = decomposeFieldWithBoustrophedon(farmland, obstacles, droneWidth, horizontalSafetyDistance)
    
    tolerance = 1e-5;
    min_subregion_area_heuristic = (droneWidth * 0.05)^2; 
    if ~(license('test', 'MAP_Toolbox') && exist('polyshape', 'class'))
        error('PathPlanning:ToolboxMissing', 'La función principal polyshape requiere Mapping Toolbox.');
    end
    hasReorient = exist('reorientboundaries', 'file') == 2;
    hasSimplify = exist('simplify', 'file') == 2;
    farmLengthX = farmland.Length; 
    farmWidthY = farmland.Width;   
    
    wasRotated = false;
    farmPoly_original = polyshape(farmland.Vertices); 
    if farmWidthY > farmLengthX
        wasRotated = true;
        disp('    El ancho del campo es mayor que el largo, se rotará el entorno 90 grados para la descomposición.');
        farmPoly_working = rotate(farmPoly_original, -90, [0 0]);
        
        obstacles_working_polys_raw = cell(1, numel(obstacles));
        for i = 1:numel(obstacles)
            % Usar PlanningFootprintVertices para la rotación
            if isfield(obstacles{i}, 'PlanningFootprintVertices') && ~isempty(obstacles{i}.PlanningFootprintVertices)
                obs_poly_orig_for_planning = polyshape(obstacles{i}.PlanningFootprintVertices);
                obstacles_working_polys_raw{i} = rotate(obs_poly_orig_for_planning, -90, [0 0]);
            else
                obstacles_working_polys_raw{i} = polyshape(); 
            end
        end
    else
        farmPoly_working = farmPoly_original;
        obstacles_working_polys_raw = cell(1, numel(obstacles));
        for i = 1:numel(obstacles)
             if isfield(obstacles{i}, 'PlanningFootprintVertices') && ~isempty(obstacles{i}.PlanningFootprintVertices)
                obstacles_working_polys_raw{i} = polyshape(obstacles{i}.PlanningFootprintVertices);
             else
                obstacles_working_polys_raw{i} = polyshape(); 
             end
        end
    end
    if hasReorient && ~isempty(farmPoly_working.Vertices), farmPoly_working = reorientboundaries(farmPoly_working); end
    if hasSimplify && ~isempty(farmPoly_working.Vertices), farmPoly_working = simplify(farmPoly_working, 'Tolerance', tolerance); end
    
    bufferedObstaclePolys_working = {};
    if ~isempty(obstacles_working_polys_raw)
        % El buffer se aplica a los polyshapes ya creados basados en PlanningFootprintVertices
        tempBufferedObstacles = createBufferedObstaclePolygons(obstacles_working_polys_raw, horizontalSafetyDistance, hasReorient, hasSimplify);
        for k_obs = 1:length(tempBufferedObstacles)
            if ~isempty(tempBufferedObstacles{k_obs}.Vertices)
                bufferedObstaclePolys_working{end+1} = tempBufferedObstacles{k_obs};
            end
        end
    end
    fprintf('    Número de polígonos de obstáculos con buffer válidos para descomposición (basado en huella de planificación): %d\n', numel(bufferedObstaclePolys_working));
    
    criticalXCoords = [];
    if ~isempty(farmPoly_working.Vertices)
        [farm_x_bounds_working, ~] = boundingbox(farmPoly_working);
        criticalXCoords = [criticalXCoords; farm_x_bounds_working(1); farm_x_bounds_working(2)];
    end
    for i = 1:numel(bufferedObstaclePolys_working) % Usar huella de planificación con buffer
        if ~isempty(bufferedObstaclePolys_working{i}.Vertices)
            [obs_x_bounds, ~] = boundingbox(bufferedObstaclePolys_working{i});
            criticalXCoords = [criticalXCoords; obs_x_bounds(1); obs_x_bounds(2)];
        end
    end
    
    if isempty(criticalXCoords)
        disp('Advertencia: No se encontraron coordenadas X críticas. El campo de cultivo podría estar vacío.');
        subregions = {};
        return;
    end
    
    criticalXCoords = unique(sort(criticalXCoords));
    if length(criticalXCoords) > 1
        criticalXCoords = criticalXCoords([true; diff(criticalXCoords) > tolerance]);
    end
    
    decomposedRegions_working = [];
    if length(criticalXCoords) < 2
        disp('Advertencia: Coordenadas X críticas insuficientes (<2) para formar franjas. Se considerará todo el campo (menos obstáculos) como una subregión.');
        currentFreeAreaPoly = farmPoly_working;
        for obs_idx = 1:numel(bufferedObstaclePolys_working)
            currentFreeAreaPoly = subtract(currentFreeAreaPoly, bufferedObstaclePolys_working{obs_idx});
        end
        if ~isempty(currentFreeAreaPoly.Vertices)
            decomposedRegions_working = currentFreeAreaPoly.regions();
        end
    else
        [~, farm_y_bounds_working] = boundingbox(farmPoly_working);
        y_min_slice = farm_y_bounds_working(1) - tolerance; 
        y_max_slice = farm_y_bounds_working(2) + tolerance;
        for i = 1:(length(criticalXCoords) - 1)
            x_start_slice = criticalXCoords(i);
            x_end_slice = criticalXCoords(i+1);
            if (x_end_slice - x_start_slice) < tolerance 
                continue;
            end
            slicePoly = polyshape([x_start_slice, y_min_slice;
                                   x_end_slice,   y_min_slice;
                                   x_end_slice,   y_max_slice;
                                   x_start_slice, y_max_slice]);
            
            currentCell = intersect(farmPoly_working, slicePoly);
            if currentCell.NumRegions == 0 || currentCell.area < min_subregion_area_heuristic
                continue;
            end
            currentFreeAreaPoly = currentCell;
            for obs_idx = 1:numel(bufferedObstaclePolys_working)
                active_obstacle_in_slice = intersect(bufferedObstaclePolys_working{obs_idx}, currentCell);
                if active_obstacle_in_slice.NumRegions > 0 && active_obstacle_in_slice.area > tolerance^2
                    currentFreeAreaPoly = subtract(currentFreeAreaPoly, bufferedObstaclePolys_working{obs_idx});
                end
            end
            
            if currentFreeAreaPoly.NumRegions > 0 && ~isempty(currentFreeAreaPoly.Vertices)
                regionsInSlice = currentFreeAreaPoly.regions();
                for r_idx = 1:length(regionsInSlice)
                    if regionsInSlice(r_idx).area > min_subregion_area_heuristic && ~isempty(regionsInSlice(r_idx).Vertices)
                        decomposedRegions_working = [decomposedRegions_working, regionsInSlice(r_idx)]; %#ok<AGROW>
                    end
                end
            end
        end
    end
    
    if isempty(decomposedRegions_working) && ~isempty(farmPoly_working.Vertices)
        disp('Sugerencia: La descomposición en franjas no produjo regiones válidas, intentando usar todo el campo (menos obstáculos) como subregión.');
        currentFreeAreaPoly = farmPoly_working;
        for obs_idx = 1:numel(bufferedObstaclePolys_working)
            currentFreeAreaPoly = subtract(currentFreeAreaPoly, bufferedObstaclePolys_working{obs_idx});
        end
        if ~isempty(currentFreeAreaPoly.Vertices)
            decomposedRegions_working = currentFreeAreaPoly.regions();
        end
    end
    
    subregions_list = {};
    subregionCounter = 0;
    for k_reg = 1:length(decomposedRegions_working)
        subPoly_working = decomposedRegions_working(k_reg);
        if subPoly_working.NumRegions == 0 || subPoly_working.area < min_subregion_area_heuristic || isempty(subPoly_working.Vertices)
            continue;
        end
        
        if hasSimplify, subPoly_working = simplify(subPoly_working, 'Tolerance', tolerance); end
        if subPoly_working.NumRegions == 0 || isempty(subPoly_working.Vertices), continue; end
        
        subPoly_final_coords_shape = subPoly_working;
        if wasRotated
            subPoly_final_coords_shape = rotate(subPoly_working, 90, [0 0]); 
            if hasSimplify, subPoly_final_coords_shape = simplify(subPoly_final_coords_shape, 'Tolerance', tolerance); end
            if subPoly_final_coords_shape.NumRegions == 0 || isempty(subPoly_final_coords_shape.Vertices), continue; end
        end
        
        if isempty(subPoly_final_coords_shape.Vertices) || area(subPoly_final_coords_shape) < min_subregion_area_heuristic
            continue;
        end
        
        subregionCounter = subregionCounter + 1;
        [centX, centY] = centroid(subPoly_final_coords_shape);
        
        sub_vertices = subPoly_final_coords_shape.Vertices;
        minX_sub = min(sub_vertices(:,1)); maxX_sub = max(sub_vertices(:,1));
        minY_sub = min(sub_vertices(:,2)); maxY_sub = max(sub_vertices(:,2));
        width_sub_for_coverage = maxX_sub - minX_sub;
        height_sub_for_coverage = maxY_sub - minY_sub;
        
        optimalAngleForCoverage = 0; 
        if height_sub_for_coverage > width_sub_for_coverage
            optimalAngleForCoverage = 90; 
        end
        
        subregions_list{end+1} = struct(...
            'ID', subregionCounter, ...
            'Vertices', subPoly_final_coords_shape.Vertices, ...
            'Centroid', [centX, centY], ...
            'OptimalSweepAngle', optimalAngleForCoverage, ...
            'Area', area(subPoly_final_coords_shape) ...
        );
    end
    subregions = subregions_list;
    fprintf('--- Descomposición Boustrophedon basada en eventos completada: Se generaron %d subregiones.\n', length(subregions));
end
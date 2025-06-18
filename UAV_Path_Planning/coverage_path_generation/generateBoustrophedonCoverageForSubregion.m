function [waypoints, entryPoint, exitPoint] = generateBoustrophedonCoverageForSubregion(subregionVertices, droneWidth, altitude, sweepAngle_deg)
   
    waypoints = []; 
    entryPoint = []; 
    exitPoint = [];
    
    tolerance = 1e-6;                          % Tolerancia para cálculos numéricos
    minSegmentLength = droneWidth * 0.1;  % Longitud mínima del segmento de ruta
    PATH_TYPE_WORK = 2;              % Identificador de segmento de trabajo
    PATH_TYPE_TURN = 3;                 % Identificador de segmento de giro
    
    subPoly = polyshape(subregionVertices, 'KeepCollinearPoints', true);
    
    if exist('reorientboundaries', 'file') == 2
        subPoly = reorientboundaries(subPoly);
    end
    
    if exist('simplify', 'file') == 2
        subPoly = simplify(subPoly, 'Tolerance', tolerance*5);
    end
    
    [poly_centroid_x, poly_centroid_y] = centroid(subPoly);
    
    subPoly_centered = translate(subPoly, -[poly_centroid_x, poly_centroid_y]);
    
    subPolyRot_centered = rotate(subPoly_centered, -sweepAngle_deg, [0,0]);
    
    subPolyRot = translate(subPolyRot_centered, [poly_centroid_x, poly_centroid_y]);
    
    [limX_subregion_rot, limY_subregion_rot] = boundingbox(subPolyRot);
    yMinRot = limY_subregion_rot(1);
    yMaxRot = limY_subregion_rot(2);
    xMin_subregion_rot = limX_subregion_rot(1);
    xMax_subregion_rot = limX_subregion_rot(2);
    
    [boundaryX_rot, boundaryY_rot] = boundary(subPolyRot);
    
    if (yMaxRot - yMinRot) < (droneWidth - tolerance)

        y_center_rot = yMinRot + (yMaxRot - yMinRot)/2;
        sweepLineSegment_rot = [xMin_subregion_rot - tolerance, y_center_rot; 
                                xMax_subregion_rot + tolerance, y_center_rot];
        

        [xi_narrow, ~] = polyxpoly(sweepLineSegment_rot(:,1), sweepLineSegment_rot(:,2), ...
                                  boundaryX_rot, boundaryY_rot);
        
        if ~isempty(xi_narrow) && length(xi_narrow) >= 2

            xi_narrow_sorted = sort(xi_narrow);
            startWP_rot_narrow = [xi_narrow_sorted(1), y_center_rot, altitude];
            endWP_rot_narrow = [xi_narrow_sorted(end), y_center_rot, altitude];
            

            startWP_orig_centered_narrow = rotate2DPointAroundOrigin(...
                startWP_rot_narrow(1:2) - [poly_centroid_x, poly_centroid_y], ...
                sweepAngle_deg);
            endWP_orig_centered_narrow = rotate2DPointAroundOrigin(...
                endWP_rot_narrow(1:2) - [poly_centroid_x, poly_centroid_y], ...
                sweepAngle_deg);
            
            entryPoint = [startWP_orig_centered_narrow + [poly_centroid_x, poly_centroid_y], altitude];
            exitPoint = [endWP_orig_centered_narrow + [poly_centroid_x, poly_centroid_y], altitude];
            

            if norm(entryPoint(1:2) - exitPoint(1:2)) > minSegmentLength
                waypoints = [entryPoint, PATH_TYPE_WORK; exitPoint, PATH_TYPE_WORK]; % [x,y,z, tipo]
            else

                [cx_orig, cy_orig] = centroid(subPoly);
                entryPoint = [cx_orig, cy_orig, altitude];
                exitPoint = entryPoint;
                waypoints = [entryPoint, PATH_TYPE_WORK];
            end
        else
            [cx_orig, cy_orig] = centroid(subPoly);
            entryPoint = [cx_orig, cy_orig, altitude];
            exitPoint = entryPoint;
            waypoints = [entryPoint, PATH_TYPE_WORK];
        end
        
        return;
    end
    
    first_sweep_y_rot = yMinRot + droneWidth / 2;
    last_sweep_y_rot = yMaxRot - droneWidth / 2;
    
    if first_sweep_y_rot > last_sweep_y_rot + tolerance
        sweepYs_rot = [yMinRot + (yMaxRot - yMinRot)/2];
    else
        sweepYs_rot = (first_sweep_y_rot : droneWidth : last_sweep_y_rot)';
        
        if ~isempty(sweepYs_rot) && abs(sweepYs_rot(end) - last_sweep_y_rot) > tolerance * droneWidth
            if sweepYs_rot(end) < last_sweep_y_rot
                sweepYs_rot = [sweepYs_rot; last_sweep_y_rot];
            end
        elseif isempty(sweepYs_rot) 
            sweepYs_rot = [first_sweep_y_rot];
        end
    end
    
    if isempty(sweepYs_rot)
        return;
    end
    
    sweepYs_rot = unique(sweepYs_rot);
    
    all_raw_segments_rot = [];
    current_sweep_direction = 1;  
    
    for i_sweep = 1:length(sweepYs_rot)
        y_current_sweep_rot = sweepYs_rot(i_sweep);
        
        horizontal_sweep_line_rot = [xMin_subregion_rot - tolerance, y_current_sweep_rot;
                                    xMax_subregion_rot + tolerance, y_current_sweep_rot];
        
        [xi_intersect, ~] = polyxpoly(horizontal_sweep_line_rot(:,1), horizontal_sweep_line_rot(:,2),...
                                     boundaryX_rot, boundaryY_rot);
        
        if ~isempty(xi_intersect) && length(xi_intersect) >= 2
            xi_sorted = sort(unique(xi_intersect));
            
            for k_pair = 1:2:(length(xi_sorted)-1)
                x_start_segment = xi_sorted(k_pair);
                x_end_segment = xi_sorted(k_pair+1);
                
                if abs(x_end_segment - x_start_segment) >= minSegmentLength
                    all_raw_segments_rot = [all_raw_segments_rot; struct('y', y_current_sweep_rot, ...
                        'x_start_abs', min(x_start_segment, x_end_segment), ...
                        'x_end_abs', max(x_start_segment, x_end_segment), ...
                        'direction', current_sweep_direction)];
                end
            end
        end
        
        current_sweep_direction = current_sweep_direction * -1;
    end
    
    if isempty(all_raw_segments_rot)
        return;
    end
    
    waypoints_rot_typed = []; 
    last_added_wp_rot = [];       
    for i_seg = 1:length(all_raw_segments_rot)
        segment = all_raw_segments_rot(i_seg);
        y_seg_rot = segment.y;
        
        if segment.direction == 1 
            startX_seg_rot = segment.x_start_abs;
            endX_seg_rot = segment.x_end_abs;
        else 
            startX_seg_rot = segment.x_end_abs;
            endX_seg_rot = segment.x_start_abs;
        end
        
        startWP_seg_rot = [startX_seg_rot, y_seg_rot, altitude];
        endWP_seg_rot = [endX_seg_rot, y_seg_rot, altitude];
        
        if isempty(waypoints_rot_typed)

            waypoints_rot_typed = [startWP_seg_rot, PATH_TYPE_WORK];
            last_added_wp_rot = startWP_seg_rot;
        else
            prev_wp_rot = last_added_wp_rot(1:3); 
            
            turnWP1_rot = [prev_wp_rot(1), y_seg_rot, altitude]; 
            
            if norm(turnWP1_rot - prev_wp_rot) > tolerance 
                waypoints_rot_typed = [waypoints_rot_typed; turnWP1_rot, PATH_TYPE_TURN];
                last_added_wp_rot = turnWP1_rot;
            end
            
            if norm(startWP_seg_rot - last_added_wp_rot(1:3)) > tolerance 
                waypoints_rot_typed = [waypoints_rot_typed; startWP_seg_rot, PATH_TYPE_TURN];
                last_added_wp_rot = startWP_seg_rot;
            end
        end
        
        if isempty(last_added_wp_rot) || norm(endWP_seg_rot - last_added_wp_rot(1:3)) > tolerance
            waypoints_rot_typed = [waypoints_rot_typed; endWP_seg_rot, PATH_TYPE_WORK];
            last_added_wp_rot = endWP_seg_rot;
        end
    end
    
    if isempty(waypoints_rot_typed)
        return;
    end
    
    waypoints = zeros(size(waypoints_rot_typed)); 
    
    for k_wp = 1:size(waypoints_rot_typed, 1)
        point_to_rotate_centered = waypoints_rot_typed(k_wp, 1:2) - [poly_centroid_x, poly_centroid_y];
        
        rotated_back_point_centered = rotate2DPointAroundOrigin(point_to_rotate_centered, sweepAngle_deg);
        
        original_coords_point = rotated_back_point_centered + [poly_centroid_x, poly_centroid_y];
        
        waypoints(k_wp, :) = [original_coords_point, altitude, waypoints_rot_typed(k_wp, 4)];
    end
    
    % Eliminar puntos de ruta demasiado cercanos
    if size(waypoints, 1) > 1
        valid_indices_final = [true; vecnorm(diff(waypoints(:,1:3), 1, 1), 2, 2) > tolerance];
        waypoints = waypoints(valid_indices_final, :);
    end
    
    % Establecer punto de entrada y salida
    if ~isempty(waypoints)
        entryPoint = waypoints(1, 1:3);
        exitPoint = waypoints(end, 1:3);
    else
        [cx_orig, cy_orig] = centroid(subPoly);
        entryPoint = [cx_orig, cy_orig, altitude];
        exitPoint = entryPoint;
        waypoints = [entryPoint, PATH_TYPE_WORK]; 
    end
end

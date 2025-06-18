function clear = isLineOfSightClear(worldPt1_xy, worldPt2_xy, gridMap, mapOrigin_xy, gridResolution, mapSize_rc)

    
    grid_c1_float = (worldPt1_xy(1) - mapOrigin_xy(1)) / gridResolution + 0.5; 
    grid_r1_float = (worldPt1_xy(2) - mapOrigin_xy(2)) / gridResolution + 0.5;
    grid_c2_float = (worldPt2_xy(1) - mapOrigin_xy(1)) / gridResolution + 0.5;
    grid_r2_float = (worldPt2_xy(2) - mapOrigin_xy(2)) / gridResolution + 0.5;
    clear = true;
    

    c1 = round(grid_c1_float); r1 = round(grid_r1_float);
    c2 = round(grid_c2_float); r2 = round(grid_r2_float);
    
    dc = abs(c2 - c1);
    dr = abs(r2 - r1);
    
    c = c1;
    r = r1;
    
    sc = 1; if c1 > c2, sc = -1; end 
    sr = 1; if r1 > r2, sr = -1; end
    
    err_val = dc - dr; 
    
% Comprobar celda de inicio
    if c >= 1 && c <= mapSize_rc(2) && r >= 1 && r <= mapSize_rc(1) % Dentro de los límites del mapa
        if gridMap(r, c) 
            clear = false; return;
        end
    else 
    end
    
    while ~(c == c2 && r == r2)      % Hasta alcanzar la celda final
        e2 = 2 * err_val;
        if e2 > -dr       % Tendencia a moverse horizontalmente
            err_val = err_val - dr;
            c = c + sc;
        end
        if e2 < dc     % Tendencia a moverse verticalmente
            err_val = err_val + dc;
            r = r + sr;
        end
        
   % Comprobar celda actual
        if c >= 1 && c <= mapSize_rc(2) && r >= 1 && r <= mapSize_rc(1) % Dentro de los límites
            if gridMap(r, c)
                clear = false;
                return;
            end
        else 
            
        end
    end
end


function displayObstacleInfo(obstacles)
    disp(repmat('=', 1, 45));
    disp('              INFORMACIÓN DE LOS OBSTÁCULOS');
    disp(repmat('-', 1, 45));
    fprintf('  Número total de obstáculos: %d\n', numel(obstacles));
    for i = 1:numel(obstacles)
        obs = obstacles{i}; 
        fprintf('  --- Obstáculo %d ---\n', i);
        fprintf('    Forma       : %s (Tipo: %d)\n', obs.ShapeName, obs.Type);
        H_val = obs.H; 
        H_str_display = sprintf('%.2f m', H_val); 
        switch obs.Type 
            case 1 % Rectangular
                fprintf('    Dimensiones (Largo×Ancho×Alto): %.2f m × %.2f m × %s\n', obs.L, obs.W, H_str_display);
            case 2 % Circular (Tipo original 3)
                fprintf('    Dimensiones (Radio×Alto): %.2f m × %s\n', obs.L, H_str_display); % L es el radio
            otherwise
                fprintf('    Información de dimensiones: Desconocida o no aplicable (Tipo %d)\n', obs.Type);
        end
        fprintf('    Centro (X,Y,Z): (%.2f, %.2f, %.2f) m\n', obs.Position(1), obs.Position(2), obs.Position(3));
    end
    disp(repmat('=', 1, 45));
end
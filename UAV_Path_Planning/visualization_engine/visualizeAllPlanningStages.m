function visualizeAllPlanningStages(params)
    % Extraer parámetros principales
    farmland = params.farmland; 
    obstacles = params.obstacles;
    
    maxObsH_common = 0;
    if ~isempty(obstacles) && iscell(obstacles)
        for k_obs = 1:length(obstacles)
            if isfield(obstacles{k_obs}, 'H') && isnumeric(obstacles{k_obs}.H) && obstacles{k_obs}.H > 0
                maxObsH_common = max(maxObsH_common, obstacles{k_obs}.H);
            end
        end
    end
    if maxObsH_common == 0 && ~isempty(obstacles) 
        maxObsH_common = 3.0; 
    end
    
    figureName_env = 'Gráfico: Entorno 3D (Campo, Obstáculos, Subregiones)';
    
    existingFig_env = findobj('Type', 'Figure', 'Name', figureName_env);
    if ~isempty(existingFig_env)
        figure(existingFig_env(1)); 
        clf(existingFig_env(1));    
        ax_env = axes('Parent', existingFig_env(1)); 
    else
        hFig_env = figure('Name', figureName_env, 'NumberTitle', 'off', ...
                          'Color', [0.97, 0.97, 1.0], 'Position', [50, 100, 800, 650]); 
        ax_env = axes('Parent', hFig_env);
    end
    
    hold(ax_env, 'on'); 
    
    zLimit_env = [0, max(maxObsH_common, 5.0) + 5.0]; 
    axisPadding_env = max(diff(farmland.XRange), diff(farmland.YRange)) * 0.1; 
    axisPadding_env = max(axisPadding_env, 5.0); 
    xLimit_env = [farmland.XRange(1) - axisPadding_env, farmland.XRange(2) + axisPadding_env];
    yLimit_env = [farmland.YRange(1) - axisPadding_env, farmland.YRange(2) + axisPadding_env];
    
    renderFarmland(ax_env, farmland); 
    renderObstacles(ax_env, obstacles);   
    renderSubregions(ax_env, params.subregions); 
    
    title(ax_env, 'Vista General del Entorno 3D: Campo, Obstáculos y División en Subregiones', 'FontSize', 14, 'FontWeight', 'bold');
    hold(ax_env, 'off'); 
    axis(ax_env, 'equal'); 
    grid(ax_env, 'on');    
    view(ax_env, -30, 25); 
    rotate3d(ax_env, 'on');
    xlim(ax_env, xLimit_env);
    ylim(ax_env, yLimit_env);
    zlim(ax_env, zLimit_env);
    xlabel(ax_env, 'Coordenada X (m)', 'FontSize', 12);
    ylabel(ax_env, 'Coordenada Y (m)', 'FontSize', 12);
    zlabel(ax_env, 'Coordenada Z (Altura, m)', 'FontSize', 12);
    setupSceneLightingAndMaterial(ax_env); 
    disp(['--- Gráfico de vista general del entorno 3D (', figureName_env, ') generado.---']);
    
    % Generar gráfico de planificación de ruta completa
    figureName_main = 'Gráfico: Entorno 3D, Subregiones y Planificación de Ruta Completa';
    
    % Comprobar si existe una ventana gráfica con el mismo nombre
    existingFig_main = findobj('Type', 'Figure', 'Name', figureName_main);
    if ~isempty(existingFig_main)
        figure(existingFig_main(1));
        clf(existingFig_main(1));
        ax_main = axes('Parent', existingFig_main(1));
    else
        hFig_main = figure('Name', figureName_main, 'NumberTitle', 'off', ...
                           'Color', [0.98, 1.0, 0.98], 'Position', [860, 100, 850, 650]);
        ax_main = axes('Parent', hFig_main);
    end
    
    hold(ax_main, 'on');
    
    % Extraer parámetros de plantas y ruta
    plants = params.plants;
    fullPath = params.fullPath;
    enablePlants = params.enablePlants; % Si se deben dibujar las plantas
    
    % Determinar límites de altura
    maxPlantH = 0.5; 
    if enablePlants && isfield(plants, 'Height') && plants.Height > 0
        maxPlantH = plants.Height;
    end
    maxDroneAlt = params.drone.Altitude;
    zLimit_main = [0, max([maxObsH_common, maxPlantH, maxDroneAlt, 5.0]) + 5.0]; 
    xLimit_main = xLimit_env; 
    yLimit_main = yLimit_env;
    
    % Dibujar elementos del gráfico de planificación
    renderFarmland(ax_main, farmland);
    renderObstacles(ax_main, obstacles);
    if enablePlants
        renderPlants(ax_main, plants); 
    end
    renderSubregions(ax_main, params.subregions);
    renderDronePath(ax_main, fullPath); 
    
    % Establecer propiedades del gráfico
    title(ax_main, 'Entorno 3D, Subregiones y Ruta Completa del Dron', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Añadir leyenda
    h_legend_handles = gobjects(0); 
    if ~isempty(fullPath)
        legend_entries = {'Ruta de Trabajo (línea azul continua)', 'Ruta Sin Trabajo (línea amarilla discontinua)', 
                         'Punto de Inicio (círculo verde)', 'Punto Final (cuadrado rojo)'};
        h_legend_handles = gobjects(length(legend_entries), 1);
        
        % Crear elementos de leyenda (dibujando elementos ficticios fuera de la vista)
        h_legend_handles(1) = plot3(ax_main, NaN, NaN, NaN, '-b', 'LineWidth', 1.5, ...
                                    'DisplayName', legend_entries{1});
        h_legend_handles(2) = plot3(ax_main, NaN, NaN, NaN, '--', 'Color', [1 0.8 0], ...
                                    'LineWidth', 1.0, 'DisplayName', legend_entries{2});
        h_legend_handles(3) = plot3(ax_main, NaN, NaN, NaN, 'o', 'MarkerFaceColor', [0 1 0], ...
                                    'MarkerEdgeColor', 'k', 'DisplayName', legend_entries{3});
        h_legend_handles(4) = plot3(ax_main, NaN, NaN, NaN, 's', 'MarkerFaceColor', [1 0 0], ...
                                    'MarkerEdgeColor', 'k', 'DisplayName', legend_entries{4});
        
        legend(ax_main, h_legend_handles, 'Location', 'northeastoutside', 'FontSize', 10);
    end
    
    % Completar configuración del gráfico
    hold(ax_main, 'off');
    axis(ax_main, 'equal');
    grid(ax_main, 'on');
    view(ax_main, -45, 35); % Vista 3D diferente para este gráfico
    rotate3d(ax_main, 'on');
    xlim(ax_main, xLimit_main);
    ylim(ax_main, yLimit_main);
    zlim(ax_main, zLimit_main);
    xlabel(ax_main, 'Coordenada X (m)', 'FontSize', 12);
    ylabel(ax_main, 'Coordenada Y (m)', 'FontSize', 12);
    zlabel(ax_main, 'Coordenada Z (m)', 'FontSize', 12);
    setupSceneLightingAndMaterial(ax_main);
    
    disp(['---Gráfico principal de planificación de ruta (', figureName_main, ') generado.---']);
end
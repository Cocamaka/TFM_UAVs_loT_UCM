function renderObstacles(ax, obstacles_list)
    % Colores y propiedades predeterminadas para los obstáculos
    obsFaceColor = [0.8,0.3,0.3]; % Rojo ladrillo
    obsFaceAlpha = 0.65;          % Transparencia
    obsEdgeColor = [0.4,0.1,0.1]; % Borde rojo oscuro
    defaultObsHeight = 3.0;       % Altura predeterminada si no se especifica
    
    for i = 1:numel(obstacles_list) 
        obs = obstacles_list{i}; 
        xc = obs.Position(1); yc = obs.Position(2); H_obs = obs.H; 
        L_obs = obs.L; W_obs = obs.W; type_obs = obs.Type; % Se eliminó angle_rot_deg
        
        if isnan(H_obs) || H_obs <= 0, H_obs = defaultObsHeight; end % Usar altura predeterminada si es inválida
        
        switch type_obs 
            case 1 % Rectangular (cuboide)
                renderCuboidObstacle(ax, xc, yc, L_obs, W_obs, H_obs, obsFaceColor, obsFaceAlpha, obsEdgeColor); % Se eliminó el ángulo de rotación
            case 2 % Circular (cilindro)
                renderCylindricalObstacle(ax, xc, yc, L_obs, H_obs, obsFaceColor, obsFaceAlpha, obsEdgeColor); % L_obs es el radio
            otherwise % Tipo desconocido
                plot3(ax,xc,yc,H_obs/2,'kx','MarkerSize',10,'LineWidth',2,'DisplayName',sprintf('Obs Tipo Desconocido %d',i));
        end
        % Añadir etiqueta de texto para el obstáculo
        text(ax, xc,yc,H_obs+1.5,sprintf('Obs %d',i),'HorizontalAlignment','center','VerticalAlignment','bottom', ...
             'Color','k','FontSize',9,'FontWeight','normal','BackgroundColor',[1,1,1,0.7],'HandleVisibility','off');
    end
end

function renderCylindricalObstacle(ax, xc, yc, radius, H, faceColor, faceAlpha, edgeColor)
    % Dibuja un obstáculo cilíndrico
    nSides_approx=24; % Número de lados para aproximar el círculo
    [X_cyl_unit,Y_cyl_unit,Z_cyl_unit]=cylinder(radius,nSides_approx); % Cilindro unitario (radio 1, altura 1)
    
    % Escalar y trasladar el cilindro
    X_cyl_abs=X_cyl_unit+xc;         % Trasladar X
    Y_cyl_abs=Y_cyl_unit+yc;         % Trasladar Y
    Z_cyl_abs=Z_cyl_unit*H;          % Escalar altura (base en z=0)
    
    % Dibujar la superficie lateral del cilindro
    surf(ax,X_cyl_abs,Y_cyl_abs,Z_cyl_abs,'FaceColor',faceColor,'EdgeColor','none','FaceAlpha',faceAlpha,'HandleVisibility','off');
    % Dibujar las tapas del cilindro
    patch(ax,X_cyl_abs(1,:),Y_cyl_abs(1,:),Z_cyl_abs(1,:),faceColor,'EdgeColor',edgeColor,'FaceAlpha',faceAlpha,'LineWidth',0.8,'HandleVisibility','off'); % Tapa inferior
    patch(ax,X_cyl_abs(2,:),Y_cyl_abs(2,:),Z_cyl_abs(2,:),faceColor,'EdgeColor',edgeColor,'FaceAlpha',faceAlpha,'LineWidth',0.8,'HandleVisibility','off'); % Tapa superior
end
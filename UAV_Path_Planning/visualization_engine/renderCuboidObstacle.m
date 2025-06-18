function renderCuboidObstacle(ax, xc, yc, L, W, H, faceColor, faceAlpha, edgeColor) 
    halfL = L/2; 
    halfW = W/2; 
    
    % Vértices del cuboide en coordenadas absolutas (base en z=0)
    verts_absolute = [
        xc-halfL, yc-halfW, 0;     
        xc+halfL, yc-halfW, 0;     
        xc+halfL, yc+halfW, 0;     
        xc-halfL, yc+halfW, 0;    
        xc-halfL, yc-halfW, H;   
        xc+halfL, yc-halfW, H;    
        xc+halfL, yc+halfW, H;   
        xc-halfL, yc+halfW, H      
    ];
    

    faces_indices = [
        1, 2, 3, 4;   
        5, 6, 7, 8;  
        1, 2, 6, 5;   
        2, 3, 7, 6;    
        3, 4, 8, 7;    
        4, 1, 5, 8     
    ];
    
    patch(ax, 'Vertices', verts_absolute, 'Faces', faces_indices, ...
        'FaceColor', faceColor, 'FaceAlpha', faceAlpha, ...
        'EdgeColor', edgeColor, 'LineWidth', 0.8, 'HandleVisibility', 'off');
end
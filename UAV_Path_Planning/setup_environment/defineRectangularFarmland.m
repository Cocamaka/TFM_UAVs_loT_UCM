function farmland = defineRectangularFarmland()
    prompt = {'Longitud del campo de cultivo (Dirección X, m):', 'Ancho del campo de cultivo (Dirección Y, m):'};
    dlgtitle = 'Definición de parámetros del campo de cultivo';
    dims = [1 35];
    defaultAns = {'100', '70'}; 
    
    answer = inputdlg(prompt, dlgtitle, dims, defaultAns);
    
    L = str2double(answer{1}); 
    W = str2double(answer{2}); 
    
    vertices = [0 0; L 0; L W; 0 W]; 
    area = L * W;                   
    xRange = [0, L]; 
    yRange = [0, W]; 
    
    farmland = struct('Vertices', vertices, 'Length', L, 'Width', W, 'Area', area, ...
                      'XRange', xRange, 'YRange', yRange, 'ShapeType', 1, 'ShapeName', 'Campo de cultivo rectangular');
    disp('--- Campo de cultivo rectangular generado. ---');
end


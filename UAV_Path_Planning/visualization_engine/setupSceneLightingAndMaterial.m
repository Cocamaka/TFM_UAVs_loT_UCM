function setupSceneLightingAndMaterial(ax)
    camlight(ax, 'headlight');   % Añadir una luz que sigue a la cámara
    lighting(ax, 'gouraud');     % Usar sombreado Gouraud para superficies suaves
    material(ax, 'dull');        % Usar material opaco para los objetos
end
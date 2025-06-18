function displayPlantInfo(plants)
    disp(repmat('=', 1, 40));
    disp('           INFORMACIÓN DE LAS PLANTAS');
    disp(repmat('-', 1, 40));
    fprintf('  Número objetivo     : %d\n', plants.TargetCount);
    fprintf('  Número real generado: %d\n', plants.Count);
    fprintf('  Altura de la planta : %.2f m\n', plants.Height);
    fprintf('  Diámetro del dosel  : %.2f m\n', plants.Diameter);
    fprintf('  Distancia entre hileras: %.2f m\n', plants.RowSpacing);
    fprintf('  Distancia entre plantas: %.2f m\n', plants.PlantSpacing);
    fprintf('  Área total de siembra: %.2f m²\n', plants.PlantingArea);
    fprintf('  Ratio de cobertura del campo: %.2f %%\n', plants.CoverageRatio);
    disp(repmat('=', 1, 40));
end
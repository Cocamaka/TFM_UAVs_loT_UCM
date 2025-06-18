function displayFarmlandInfo(farmland)
    disp(repmat('=', 1, 40));
    disp('           INFORMACIÓN DEL CAMPO DE CULTIVO');
    disp(repmat('-', 1, 40));
    fprintf('  Forma       : %s\n', farmland.ShapeName);
    fprintf('  Dimensiones (LxA): %.2f m × %.2f m\n', farmland.Length, farmland.Width);
    fprintf('  Área        : %.2f m²\n', farmland.Area);
    fprintf('  Rango X     : [%.2f, %.2f] m\n', farmland.XRange(1), farmland.XRange(2));
    fprintf('  Rango Y     : [%.2f, %.2f] m\n', farmland.YRange(1), farmland.YRange(2));
    disp(repmat('=', 1, 40));
end
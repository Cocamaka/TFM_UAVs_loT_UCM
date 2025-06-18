function worldCoordsXY = convertGridToWorldCoordinates(gridCoordsRC, mapOriginXY, gridResolution, ~) % mapSizeRC ya no se usa
    row = gridCoordsRC(1); 
    col = gridCoordsRC(2);
    x_coord_center = mapOriginXY(1) + (col - 1 + 0.5) * gridResolution; % Centro X de la celda
    y_coord_center = mapOriginXY(2) + (row - 1 + 0.5) * gridResolution; % Centro Y de la celda
    worldCoordsXY = [x_coord_center, y_coord_center];
end
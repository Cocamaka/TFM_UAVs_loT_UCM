function gridCoordsRC = convertWorldToGridCoordinates(worldCoordsXY, mapOriginXY, gridResolution)

    col = floor((worldCoordsXY(1) - mapOriginXY(1)) / gridResolution) + 1; % Columna (asociada con X)
    row = floor((worldCoordsXY(2) - mapOriginXY(2)) / gridResolution) + 1; % Fila (asociada con Y)
    gridCoordsRC = [row, col];
end
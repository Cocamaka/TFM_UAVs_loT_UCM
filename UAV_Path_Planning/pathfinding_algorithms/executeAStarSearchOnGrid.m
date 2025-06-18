function gridPathIndices = executeAStarSearchOnGrid(startGridRC, endGridRC, gridMap)
    
    [numRows, numCols] = size(gridMap);
    gridPathIndices = []; % Inicializar como vacío, indica que no se encontró la ruta por defecto

    gCost = inf(numRows, numCols);  % Costo real desde el inicio hasta el punto actual
    fCost = inf(numRows, numCols);  % Costo g + costo heurístico
    parent = zeros(numRows, numCols, 2);  
    

    heuristic = @(r, c) abs(r - endGridRC(1)) + abs(c - endGridRC(2));
    
    startRow = startGridRC(1);
    startCol = startGridRC(2);
    
    if gridMap(startRow, startCol)
    end
    if gridMap(endGridRC(1), endGridRC(2))
    end
    
    gCost(startRow, startCol) = 0;
    fCost(startRow, startCol) = heuristic(startRow, startCol);
    
    % openList almacena: [fCost, gCost, fila, col]
    openList = [fCost(startRow, startCol), gCost(startRow, startCol), startRow, startCol];
    closedList = false(numRows, numCols); % Nodos ya evaluados
    
    moves = [-1 0; 1 0; 0 -1; 0 1; -1 -1; -1 1; 1 -1; 1 1]; % Arriba, Abajo, Izquierda, Derecha, Diagonales
    moveCosts = [1; 1; 1; 1; sqrt(2); sqrt(2); sqrt(2); sqrt(2)]; % Costos para movimientos rectos y diagonales
    
    pathFound = false;
    
    % Bucle principal de búsqueda A*
    while ~isempty(openList)
        [~, currentMinIdxInOpen] = min(openList(:,1));
        currentNodeData = openList(currentMinIdxInOpen,:);
        openList(currentMinIdxInOpen,:) = []; 

        currentRow = currentNodeData(3);
        currentCol = currentNodeData(4);
        currentGCostFromStart = currentNodeData(2);
        
        if closedList(currentRow, currentCol)
            continue;
        end
        
        % Añadir el nodo actual a la lista cerrada
        closedList(currentRow, currentCol) = true;
        
        % Comprobar si se ha alcanzado el objetivo
        if currentRow == endGridRC(1) && currentCol == endGridRC(2)
            pathFound = true;
            break;
        end
        
        % Comprobar nodos adyacentes
        for i_move = 1:size(moves, 1)
            neighborRow = currentRow + moves(i_move, 1);
            neighborCol = currentCol + moves(i_move, 2);
            
            % Comprobar si el vecino es válido y no es un obstáculo
            if neighborRow >= 1 && neighborRow <= numRows && ...
               neighborCol >= 1 && neighborCol <= numCols && ...
               ~gridMap(neighborRow, neighborCol) && ... % Asegurar que el vecino sea transitable
               ~closedList(neighborRow, neighborCol)    % Y no esté en la lista cerrada
                
                % Calcular el costo hasta el vecino
                tentativeGCostToNeighbor = currentGCostFromStart + moveCosts(i_move);
                
                % Si se encuentra una ruta más corta, actualizar costo y padre
                if tentativeGCostToNeighbor < gCost(neighborRow, neighborCol)
                    gCost(neighborRow, neighborCol) = tentativeGCostToNeighbor;
                    fCost(neighborRow, neighborCol) = tentativeGCostToNeighbor + heuristic(neighborRow, neighborCol);
                    parent(neighborRow, neighborCol, :) = [currentRow, currentCol];
                    
                    % Añadir vecino a la lista abierta
                    openList = [openList; fCost(neighborRow, neighborCol), tentativeGCostToNeighbor, neighborRow, neighborCol];
                end
            end
        end
    end
    
    % Reconstruir la ruta
    if pathFound
        path_reversed = []; % Almacenará la ruta en orden inverso
        curr_trace = endGridRC; % Comenzar desde el final
        
        % Retroceder desde el final hasta el inicio
        while ~isequal(curr_trace, startGridRC)
            path_reversed = [curr_trace; path_reversed]; % Añadir punto actual al inicio de la ruta invertida
            parentRow_trace = parent(curr_trace(1), curr_trace(2), 1);
            parentCol_trace = parent(curr_trace(1), curr_trace(2), 2);
            
            if (parentRow_trace == 0 || parentCol_trace == 0) && ~isequal(curr_trace, startGridRC)
                gridPathIndices = []; 
                return; 
            end
            curr_trace = [parentRow_trace, parentCol_trace]; 
        end
        gridPathIndices = [startGridRC; path_reversed]; 
    else
        gridPathIndices = []; 
    end
end
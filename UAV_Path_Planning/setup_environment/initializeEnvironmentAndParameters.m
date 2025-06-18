
function params = initializeEnvironmentAndParameters()
    addpath(fileparts(mfilename('fullpath'))); 
    params = struct(); 
    %Opciones de simulación de plantas
    usePlantsStr = questdlg('¿Simulación y visualización de plantas?', 'Opciones de planta', 'Sí', 'No', 'No');
    params.enablePlants = strcmp(usePlantsStr, 'Sí');
    params.plants = struct('Coordinates', [], 'Count', 0, 'TargetCount', 0, 'Height', 0, 'Diameter', 0, 'PlantingArea', 0, 'CoverageRatio', 0, 'RowSpacing', 0, 'PlantSpacing', 0);
    disp('--- Parámetros de entrada manual para la información del entorno objetivo. ---');
    params.farmland = defineRectangularFarmland();
    params.obstacles = defineObstaclesInFarmland(params.farmland);
    
    if params.enablePlants
        params.plants = generatePlantDistribution(params.farmland, params.obstacles);
    else
        disp('--- No generar plantas. ---');
    end
    
    displayFarmlandInfo(params.farmland);
    displayObstacleInfo(params.obstacles);
    displayPlantInfo(params.plants); 
    
    params.drone = getDroneSpecs(); 
    displayDroneParameters(params.drone); 
    
    params.planningObstacles = bufferObstaclesForPlanning(params.obstacles, params.drone.HorizontalSafetyDistance);
    
    disp('--- Creando mapa de cuadrícula ---');
    [params.gridMap, params.gridResolution, params.mapOrigin, params.mapSize] = ...
        createOccupancyGridMap(params.farmland, params.obstacles, params.drone.HorizontalSafetyDistance);
    
    fprintf('\n--- Parte 1 completada ---\n');
end

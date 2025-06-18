function final_params = Path_Planning_loT()

    clc;
    close all;
    
    disp('===== Inicio de la planificación de ruta del dron =====');
    
    %Parte 1: Inicialización del entorno, entrada de parámetros, creación del mapa de cuadrícula
    fprintf('\n--- Parte 1: Inicialización del entorno y los parámetros ---\n');
    params_after_part1 = initializeEnvironmentAndParameters(); 
    
    %Parte 2: Descomposición del campo, ordenación de ruta ACO
    fprintf('\n--- Parte 2: Descomposición del área y ordenación de ruta ACO ---\n');
    params_after_part2 = performAreaDecompositionAndACO(params_after_part1); 
    
    %Parte 3: Generación de la ruta de cobertura completa, cálculo de métricas, visualización
    fprintf('\n--- Parte 3: Generación de ruta, cálculo de métricas y visualización ---\n');
    params_after_part3 = generateFinalPathAndVisualize(params_after_part2); 
    
    final_params = params_after_part3; 
    disp('===== Proceso de planificación de ruta completado =====');
    user_channel_id = 2962682; 
    
    %ThingSpeak
    disp('Llamando a la función uploadResultsToThingSpeak...');
    uploadResultsToThingSpeak(final_params, user_channel_id);
    disp('Fin.');
    
end
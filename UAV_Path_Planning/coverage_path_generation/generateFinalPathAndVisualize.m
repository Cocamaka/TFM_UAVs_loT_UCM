function params = generateFinalPathAndVisualize(params)
     
    % Generar ruta de cobertura completa
    params.fullPath = generateCompleteCoveragePath(params);
    disp('---Ruta de cobertura completa del dron generada---');
    fprintf('---La ruta completa contiene %d puntos de ruta.---\n', size(params.fullPath, 1));
    
    params.pathMetrics = computePathPerformanceMetrics(params);
    
    displaySubregionTraversalInfo(params); 
    displayPathMetricsSummary(params.pathMetrics); 
    visualizeAllPlanningStages(params); %
    
    disp(repmat('=',1,50));
    disp('Parte 3 finalizada');
end

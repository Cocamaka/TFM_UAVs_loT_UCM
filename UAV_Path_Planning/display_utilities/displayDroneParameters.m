function displayDroneParameters(drone)
    disp(repmat('=', 1, 40));
    disp('           PARÁMETROS DEL DRON');
    disp(repmat('-', 1, 40));
    fprintf('  Ancho de trabajo (pulverización): %.2f m\n', drone.Width);
    fprintf('  Velocidad de vuelo        : %.2f m/s\n', drone.Speed);
    fprintf('  Altitud de vuelo (Z)    : %.2f m\n', drone.Altitude);
    fprintf('  Distancia de seguridad horizontal (obstáculos): %.2f m\n', drone.HorizontalSafetyDistance);
    fprintf('  Distancia de seguridad vertical (suelo/cultivos): %.2f m\n', drone.VerticalSafetyDistance);
    fprintf('  Radio de giro de referencia: %.2f m\n', drone.TurnRadius);
    if drone.ReturnToHome, returnStr = 'Sí'; else, returnStr = 'No'; end
    fprintf('  Regresar al origen (0,0) tras la misión: %s\n', returnStr);
    disp(repmat('=', 1, 40));
end
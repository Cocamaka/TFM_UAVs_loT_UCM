function drone = getDroneSpecs() 
    prompt = {'Ancho de trabajo del dron (pulverización, m):', 'Velocidad de vuelo del dron (m/s):', ...
              'Altitud de vuelo del dron (Z, m):', 'Distancia de seguridad horizontal (con borde de obstáculos, m):', ...
              'Distancia de seguridad vertical (con suelo/parte superior de cultivos, m):', 'Radio de giro del dron (valor de referencia, m):'};
    dlgtitle = 'Definición de parámetros del dron';
    defaultAns = {'4', '10', '7', '2.5', '1.5', '2.5'}; 
    answer = inputdlg(prompt, dlgtitle, [1 55], defaultAns);
    width = str2double(answer{1}); speed = str2double(answer{2}); altitude = str2double(answer{3});
    horizontalSafetyDist = str2double(answer{4}); verticalSafetyDist = str2double(answer{5});
    turnRadius = str2double(answer{6});
    returnChoice = questdlg('Después de completar la misión, ¿el dron regresa al punto de origen (0,0)?', 'Opciones de regreso', 'Sí (Regresar)', 'No (Parar en el punto final de la misión)', 'No (Parar en el punto final de la misión)');
    returnToHome = strcmp(returnChoice, 'Sí (Regresar)');
    
    prompt_turn_time = {'Tiempo promedio de giro en operación (segundos/vez):', 'Tiempo promedio de giro en desplazamiento (segundos/vez):'};
    dlgtitle_turn_time = 'Parámetros de tiempo de giro del dron';
    defaultAns_turn_time = {'3.0', '2.0'}; 
    answer_turn_time = inputdlg(prompt_turn_time, dlgtitle_turn_time, [1 50], defaultAns_turn_time);
    time_work_turn_sec = str2double(answer_turn_time{1});
    time_travel_turn_sec = str2double(answer_turn_time{2});
    
    drone = struct('Width', width, 'Speed', speed, 'Altitude', altitude, ...
                   'HorizontalSafetyDistance', horizontalSafetyDist, ...
                   'VerticalSafetyDistance', verticalSafetyDist, ...
                   'TurnRadius', turnRadius, 'ReturnToHome', returnToHome, ...
                   'TimePerWorkTurn', time_work_turn_sec, ... 
                   'TimePerTravelTurn', time_travel_turn_sec); 
    disp('--- Parámetros del dron establecidos. ---');
end
function [bestTour_indices, bestTourLength] = executeACOForSubregionSequence(distMatrix, acoParams, returnToStartFlag)
    numTotalNodes = size(distMatrix, 1);
    if numTotalNodes <= 1 
        bestTour_indices = [];
        bestTourLength = 0;
        if numTotalNodes == 1 && numTotalNodes-1 > 0 
             bestTour_indices = 1; 

             if returnToStartFlag
                bestTourLength = distMatrix(1,2) + distMatrix(2,1); 
                bestTourLength = distMatrix(1,2);
             end
             if isinf(bestTourLength) || isnan(bestTourLength)
                 bestTourLength = 0; 
             end
        end
        return;
    end
    numActualSubregions = numTotalNodes - 1;
    numAnts = acoParams.numAnts;
    numIterations = acoParams.numIterations;
    alpha = acoParams.alpha;
    beta = acoParams.beta;
    evaporationRate = acoParams.evaporationRate;
    
    % Q_pheromone se establece internamente, ya no se obtiene de acoParams
    Q_pheromone = numActualSubregions; 
    % Q_pheromone = 1.0;
    eta = 1 ./ distMatrix; 
    eta(isinf(eta) | isnan(eta) | eta < 0) = 0; 
    
    meanDistFinite = mean(distMatrix(isfinite(distMatrix) & distMatrix > 0));
    if isnan(meanDistFinite) || meanDistFinite <= 0
        meanDistFinite = 100; 
    end
    
    tau_initial_value = 1 / (numTotalNodes * meanDistFinite); 
    tau = ones(numTotalNodes, numTotalNodes) * tau_initial_value; 
    
    bestTour_full_node_sequence = []; 
    bestTourLength = inf;           
    fixedStartNodeIndex = 1;          
    
    for iter = 1:numIterations
        allAntTours_node_sequences = cell(numAnts, 1); 
        allAntTourLengths = inf(numAnts, 1);          
        
        for ant = 1:numAnts 
            currentTour_node_sequence = zeros(1, numActualSubregions + 1); 
            currentTour_node_sequence(1) = fixedStartNodeIndex;
            visited_nodes = false(1, numTotalNodes); 
            visited_nodes(fixedStartNodeIndex) = true;
            num_nodes_in_tour = 1;
            validTourForAnt = true;
            
            for i = 1:numActualSubregions 
                currentNode = currentTour_node_sequence(i);
                unvisited_indices_all = find(~visited_nodes);
                
                if isempty(unvisited_indices_all)
                    validTourForAnt = false; break; 
                end
                
                tau_values_to_unvisited = tau(currentNode, unvisited_indices_all);
                eta_values_to_unvisited = eta(currentNode, unvisited_indices_all);
                
                valid_prob_mask = isfinite(tau_values_to_unvisited) & isfinite(eta_values_to_unvisited) & ...
                                  tau_values_to_unvisited >= 0 & eta_values_to_unvisited >= 0;
                
                if ~any(valid_prob_mask)
                    validTourForAnt = false; break; % No hay probabilidad de transición válida
                end
                
                unvisited_valid_for_prob_calc = unvisited_indices_all(valid_prob_mask);
                tau_vals_valid = tau_values_to_unvisited(valid_prob_mask);
                eta_vals_valid = eta_values_to_unvisited(valid_prob_mask);
                
                prob_numerators = (tau_vals_valid.^alpha) .* (eta_vals_valid.^beta);
                prob_numerators(isnan(prob_numerators) | isinf(prob_numerators)) = 0;
                
                totalProbSum = sum(prob_numerators);
                if totalProbSum == 0 % Si todas las probabilidades son 0, elegir equitativamente
                    if isempty(unvisited_valid_for_prob_calc)
                         validTourForAnt = false; break;
                    end
                    normalized_probs = ones(1, length(unvisited_valid_for_prob_calc)) / length(unvisited_valid_for_prob_calc);
                else
                    normalized_probs = prob_numerators / totalProbSum;
                end
                
                cumulativeProb = cumsum(normalized_probs);
                randomPick = rand;
                selected_idx_in_valid_list = find(randomPick <= cumulativeProb, 1, 'first');
                
                if isempty(selected_idx_in_valid_list)
                     validTourForAnt = false; break; 
                end
                nextNode = unvisited_valid_for_prob_calc(selected_idx_in_valid_list);
                
                currentTour_node_sequence(i+1) = nextNode;
                visited_nodes(nextNode) = true;
                num_nodes_in_tour = num_nodes_in_tour + 1;
            end
            
            if validTourForAnt && num_nodes_in_tour == (numActualSubregions + 1)
                if returnToStartFlag
                    currentTour_node_sequence(end+1) = fixedStartNodeIndex; 
                end
                allAntTours_node_sequences{ant} = currentTour_node_sequence;
                allAntTourLengths(ant) = calculateTourLengthFromDistanceMatrix(currentTour_node_sequence, distMatrix);
                
                if allAntTourLengths(ant) < bestTourLength
                    bestTourLength = allAntTourLengths(ant);
                    bestTour_full_node_sequence = currentTour_node_sequence;
                end
            else
                 allAntTourLengths(ant) = inf
            end
        end
        
        % Actualizar feromonas
        delta_tau = zeros(numTotalNodes, numTotalNodes);
        for ant_update = 1:numAnts
            if ~isinf(allAntTourLengths(ant_update)) && ~isempty(allAntTours_node_sequences{ant_update})
                tour_path = allAntTours_node_sequences{ant_update};
                pheromoneDepositAmount = Q_pheromone / allAntTourLengths(ant_update);
                for i_edge = 1:(length(tour_path) - 1)
                    node1 = tour_path(i_edge);
                    node2 = tour_path(i_edge+1);
                    delta_tau(node1, node2) = delta_tau(node1, node2) + pheromoneDepositAmount;
                    delta_tau(node2, node1) = delta_tau(node2, node1) + pheromoneDepositAmount; % Ruta simétrica
                end
            end
        end
        
        tau = (1 - evaporationRate) * tau + delta_tau; 
        min_tau_val = 1e-6; 
        tau(tau < min_tau_val) = min_tau_val;

        max_tau_val = 1 / (meanDistFinite * 0.5); % Límite superior de ejemplo
        tau(tau > max_tau_val) = max_tau_val;
        if mod(iter, 20) == 0
            fprintf('    Iteración ACO %d/%d, longitud de la mejor ruta actual: %.2f m\n', iter, numIterations, bestTourLength);
        end
    end
    
    if isempty(bestTour_full_node_sequence) && numActualSubregions > 0
        disp('Advertencia: ACO no pudo encontrar ninguna ruta válida. Se intentará el orden original (si aplica).');

        if numActualSubregions > 0
            bestTour_indices = 1:numActualSubregions; 
        else
            bestTour_indices = [];
        end
        bestTourLength = inf; 
        return;
    elseif isempty(bestTour_full_node_sequence) && numActualSubregions == 0
        bestTour_indices = [];
        bestTourLength = 0;
        return;
    end

    if returnToStartFlag
        real_subregion_nodes_in_tour = bestTour_full_node_sequence(2:end-1);
    else
        real_subregion_nodes_in_tour = bestTour_full_node_sequence(2:end);
    end
    
    bestTour_indices = real_subregion_nodes_in_tour - 1; 
end
function tourLength = calculateTourLengthFromDistanceMatrix(tour_path_node_indices, distMatrix)
    tourLength = 0;
    
    for i = 1:(length(tour_path_node_indices) - 1)
        idx1 = tour_path_node_indices(i);
        idx2 = tour_path_node_indices(i+1);
        dist_segment = distMatrix(idx1, idx2);
        tourLength = tourLength + dist_segment;
    end
end
function bufferedPolys = createBufferedObstaclePolygons(obstaclePolyshapes, safetyDistance, hasReorient, hasSimplify)
    bufferedPolys = {}; 
    simplifyTol = safetyDistance * 0.05; 
    
    for i = 1:numel(obstaclePolyshapes) 
        originalPoly = obstaclePolyshapes{i}; 
        if isempty(originalPoly.Vertices)
            continue;
        end
        
        if hasReorient
            originalPoly = reorientboundaries(originalPoly);
        end
        if hasSimplify
            originalPoly = simplify(originalPoly, 'Tolerance', simplifyTol);
            if isempty(originalPoly.Vertices), continue; end
        end
        
        currentBufferedPoly = polybuffer(originalPoly, safetyDistance, 'JointType', 'round');
        
        if hasReorient && ~isempty(currentBufferedPoly.Vertices)
            currentBufferedPoly = reorientboundaries(currentBufferedPoly);
        end
        if hasSimplify && ~isempty(currentBufferedPoly.Vertices)
            currentBufferedPoly = simplify(currentBufferedPoly, 'Tolerance', simplifyTol);
            if isempty(currentBufferedPoly.Vertices), continue; end
        end
        
        if ~isempty(currentBufferedPoly.Vertices)
             bufferedPolys{end+1} = currentBufferedPoly; 
        end
    end
end


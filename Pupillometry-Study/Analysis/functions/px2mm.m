%% this function converts pixels to mm


function px_to_mm = px2mm(px,ppi)

% px_to_mm = (25.4*px) / width; 
px_to_mm = (25.4*px) / ppi; 

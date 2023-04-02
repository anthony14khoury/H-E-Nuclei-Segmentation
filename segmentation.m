function binary_mask = segmentation(image)
    
    % segmentaion 
    [stain1, ~, ~] = colour_deconvolution(image, 'HE 2');    
    
    % Green channel
    cmap = hsv(256);
    RGB = ind2rgb(stain1,cmap);
    g = RGB(:,:,2);
    
    % Removing small dots
    BWs = bwareaopen(g,30);
    
    % Dilating
    se90 = strel('line',3,90);
    se0 = strel('line',3,0);
    BWsdil = imdilate(BWs,[se90 se0]);
    
    % Filling in holes
    BWdfill = imfill(BWsdil,'holes');
    
    % Binary Mask
    binary_mask = bwperim(BWdfill);

end
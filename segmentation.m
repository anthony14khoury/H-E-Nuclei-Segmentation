function [binary_mask_perim, binary_mask_filled] = segmentation(image)

    [counts, intensities] = imhist(image); % Calculate histogram
    mean_intensity = sum(counts .* intensities) / numel(image); % Calculate mean intensity
    variance = sum(counts .* ((intensities - mean_intensity).^2)) / numel(image); % Calculate variance
    
    % Binarize blank windows to be black
    if variance < 200
        grayscale = rgb2gray(image);
        grayscale(:,:)=0;
        binary_mask_perim = grayscale;
        binary_mask_filled = grayscale; 
        return
    end
    
    [H_stain, ~, ~] = colour_deconvolution(image, 'HE 2');
    
    a = H_stain;
    a_filterd = imgaussfilt(a,2); % gaussian filter

    enhanced_img = imadjust(a_filterd); % image enhancement

    binary_img = ~imbinarize(enhanced_img,0.4); % binarization with threshold

    binary_filled = imfill(binary_img,'holes'); % fill in holes
    binary_open = imopen(binary_filled,strel('disk',3)); % morphologically open image

    large_areas = bwareafilt(binary_open,[900 1e6]); % filter out large areas
    erode_large = imerode(large_areas,strel('disk',3)); % erode large areas to separate nucs contained
    large_nucs = bwareafilt(erode_large,[700 1e6]); % filter out overlapped nuclei/large areas
    split_large = split_nuclei_functional(large_nucs); % split large areas to find nucs
    small = bwareaopen(split_large,75); % Remove noise
    small_filtered = bwareafilt(small,[0,900]); % Filter out segmented small nuclei to add back in
   
    sub_large_nucs = binary_img-imdilate(erode_large,strel('disk',3)); % Subtract large areas/nuclei
    binary_with_small = imbinarize(sub_large_nucs) + small_filtered; % Add back in small nuclei
    final_binary_img = imbinarize(binary_with_small); % Binarize again due to adding in small nuclei
    
    % morphorlogical transform/opening
    eroded_img = imerode(final_binary_img, strel('disk', 3));
    dilated_img = imdilate(eroded_img, strel('disk', 2));
      
    dilated_filled = imfill(bwareaopen(dilated_img, 75),'holes');  % Remove small noise
    
    mask = split_nuclei_functional(dilated_filled); % Segment overlapped nuclei

    binary_mask_filled = bwareaopen(mask,75); % Remove small noise and obtain final mask
  
    binary_mask_perim = bwperim(binary_mask_filled); % Nuclei contours

end
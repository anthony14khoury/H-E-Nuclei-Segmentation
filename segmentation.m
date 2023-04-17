function [binary_mask_perim, binary_mask_filled] = segmentation(image)

    [counts, intensities] = imhist(image); % Calculate histogram
    mean_intensity = sum(counts .* intensities) / numel(image);
    variance = sum(counts .* ((intensities - mean_intensity).^2)) / numel(image);

    if variance < 50
        temp = rgb2gray(image);
        temp(:,:)=0;
        binary_mask_perim = temp;
        binary_mask_filled = temp;
        return
    end
    
    [stain1, stain2, complementary] = colour_deconvolution(image, 'HE 2');
    
    a = stain1;
    a_filterd = imgaussfilt(a,2); % gaussian filter
    
    enhanced_img = imadjust(a_filterd); % image enhancement
    
    threshold = graythresh(enhanced_img); % global thresholding
    binary_img = imbinarize(enhanced_img,threshold); binary_img = ~ binary_img; % binarize image
    
    temp = bwareafilt(binary_img,[800 20000]);
    binary_img = binary_img-temp;
    binary_img = imbinarize(binary_img);
    
    se = strel('disk', 2); % morphorlogical transform/opening
    eroded_img = imerode(binary_img, se);
    dilated_img = imdilate(eroded_img, se);
    
    % Remove small noise
    dilated_img = imfill(bwareaopen(dilated_img, 100),'holes'); % Change 100 to the desired minimum area size
    
    final_mask = split_nuclei_functional(dilated_img);
    
    final_contour = bwperim(final_mask);
    
    % Binary Mask with Perimeters
    binary_mask_perim = bwperim(final_mask);
    
    % Binary Mask Filled in
    binary_mask_filled = final_mask;

end
%% Automatically find the Smallest & Largest Images
file_name = '213_HIVE_TMA_190.7 H&E_2_003.svs';

image_info = imfinfo(file_name);
image_sizes = zeros(size(image_info));
for i = 1:size(image_info,1)
    image_sizes(i) = image_info(i).Width * image_info(i).Height;
end

index = find(image_sizes == min(image_sizes));
smallest_page = index(1);

index = find(image_sizes == max(image_sizes));
largest_page = index(1);

largest_width = image_info(largest_page).Width;
largest_height = image_info(largest_page).Height;


%%
% Get Height and Width Ratios
height_ratio = image_info(largest_page).Height / image_info(smallest_page).Height;
width_ratio = image_info(largest_page).Width / image_info(smallest_page).Width;

% Set sliding window parameters
window_size = 256;
step_size = 256;

% Extract patches using sliding window
patchIdx = 0;

total_image = [];
a = 0;
for y = 1:step_size:largest_height
    binary_row = {};
    for x = 1:step_size:largest_width
        cols = [x x+255];
        rows = [y y+255];

        if x+255 > largest_width
            cols = [x largest_width];
        end
        if y+255 > largest_height
            rows = [y largest_height];
        end

        io_roi = imread(file_name, 'Index', largest_page,'PixelRegion', {rows, cols});
        
        binary_mask = segmentation(io_roi);

        binary_row{end + 1} = binary_mask;

    end
    
    % Combine all of the images in a 
    combined_image = cat(2, cell2mat(binary_row(1)), cell2mat(binary_row(2)));
    for image = 3:size(binary_row, 2)
        combined_image = cat(2, combined_image, cell2mat(binary_row(image)));
    end
    
    total_image{end + 1} = combined_image;
end

% Combine all of the rows together vertically
combined_image = cat(1, cell2mat(total_image(1)), cell2mat(total_image(2)));
for image = 3:size(total_image, 2)
    combined_image = cat(1, combined_image, cell2mat(total_image(image)));
end

imwrite(combined_image, "binary_mask_1.png");


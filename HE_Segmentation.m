%% H&E Nuclei Segmentation
% Anthony Khoury, Rylee Faherty, and Tianyao Wei

% Project Slide Image
file_name = '213_HIVE_TMA_190.7 H&E_2_003.svs'; % Change me to file the file name of the data
output_filename1 = 'binary_mask_perim.tif'; % Change me to your desired output file name for the perimeter of the nuceli
output_filename2 = 'binary_mask_filled.tif'; % Change me to your desired output file name for the filled in nuclei

% Loop through possible pages and return the total sizes to a list
image_info = imfinfo(file_name);
image_sizes = zeros(size(image_info));
for i = 1:size(image_info,1)
    image_sizes(i) = image_info(i).Width * image_info(i).Height;
end

% Find largest page
index = find(image_sizes == max(image_sizes));
largest_page = index(1);

% Getting largest page's width and height
largest_width = image_info(largest_page).Width;
largest_height = image_info(largest_page).Height;

% Set Step Size
step_size = 256;

% Variable to store entire image
total_image_perim = [];
total_image_filled = [];
x_index = 1;
y_index = 1;
for y = 1:step_size:largest_height    % Loop through height
    binary_perim_row = {};            % Store binary data for one row
    binary_filled_row = {};             % Store binary data for one row
    for x = 1:step_size:largest_width % Loop through width
        
        % Grab ROI
        cols = [x x+255];
        rows = [y y+255];

        % Logic to get the roi for the end of an image if it is smaller
        % than 256
        if x+255 > largest_width
            cols = [x largest_width];
        end
        if y+255 > largest_height
            rows = [y largest_height];
        end
        
        % Read in ROI Image
        io_roi = imread(file_name, 'Index', largest_page, 'PixelRegion', {rows, cols});
        
        % Function to get Binary Mask with perimeters and filled in
        [binary_mask_perim, binary_mask_filled] = segmentation(io_roi);
        binary_mask_filled = logical(binary_mask_filled);
        binary_mask_perim = logical(binary_mask_perim);
        
        % Append Perim to Binary Row
        binary_perim_row{end + 1} = binary_mask_perim;
        binary_filled_row{end + 1} = binary_mask_filled;

        x_index = x_index + 1;

    end
    x_index = 0;
    y_index = y_index + 1;
    
    combined_perim_image = combine_rows(binary_perim_row);
    combined_filled_image = combine_rows(binary_filled_row);

    
    % Append the Binary Row to the Total Image
    total_image_perim{end + 1} = combined_perim_image;
    total_image_filled{end + 1} = combined_filled_image;
end

% Combine all of the rows together vertically
total_image_perim = combine_columns(total_image_perim);
total_image_filled = combine_columns(total_image_filled);

% Output the 
imwrite(total_image_perim, output_filename1, 'tif');
imwrite(total_image_filled, output_filename2, 'tif');

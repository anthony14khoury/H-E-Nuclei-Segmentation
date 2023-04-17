%% H&E Nuclei Segmentation
% Anthony Khoury, Rylee Faherty, and Tianyao Wei

%% Automatically find the Smallest & Largest Images
file_name = '213_HIVE_TMA_190.7 H&E_2_003.svs';

output_filename1 = 'binary_mask_perim_7.tif'; % Change me
output_filename2 = 'binary_mask_filled_7.tif'; % Change me

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
index = 1;
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

        index = index + 1;

    end
    
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


%% Performance Analysis
gt_image = imread("Ground Truth Image.tif");
test_image = imread("binary_mask_filled_7.tif");

TN = sum(test_image(:) == 0 & gt_image(:) == 0);
TP = sum(test_image(:) == 1 & gt_image(:) == 1);
FN = sum(test_image(:) == 0 & gt_image(:) == 1);
FP = sum(test_image(:) == 1 & gt_image(:) == 0);

f1 = TP / (TP + 0.5*(FP + FN));
precision = TP / (TP + FP);
specificity = TN / (TN + FP);
sensitivity = TP / (TP + FN);

% Compute Accuracy
diff_img = imabsdiff(gt_image, test_image);
num_pixels = numel(gt_image);
num_correct = num_pixels - nnz(diff_img);
accuracy = num_correct / num_pixels * 100;

disp(['F1 score: ', num2str(f1)])
disp(['Precision: ', num2str(precision)])
disp(['Specificity: ', num2str(specificity)])
disp(['Sensitivity: ', num2str(sensitivity)])
disp(['Accuracy: ', num2str(accuracy)])

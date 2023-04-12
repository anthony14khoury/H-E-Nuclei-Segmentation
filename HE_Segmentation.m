%% H&E Nuclei Segmentation
% Anthony Khoury, Rylee Faherty, and Tianyao Wei

%% Automatically find the Smallest & Largest Images
file_name = '213_HIVE_TMA_190.7 H&E_2_003.svs';

% Loop through possible pages and return the total sizes to a list
image_info = imfinfo(file_name);
image_sizes = zeros(size(image_info));
for i = 1:size(image_info,1)
    image_sizes(i) = image_info(i).Width * image_info(i).Height;
end

% Find smallest page
index = find(image_sizes == min(image_sizes));
smallest_page = index(1);

% Find largest page
index = find(image_sizes == max(image_sizes));
largest_page = index(1);

% Getting largest page's width and height
largest_width = image_info(largest_page).Width;
largest_height = image_info(largest_page).Height;

% Set Step Size
step_size = 256;


%%
% Variable to store entire image
total_image_perim = [];
total_image_filled = [];

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
        
        % Append Perim to Binary Row
        binary_perim_row{end + 1} = binary_mask_perim;
        binary_filled_row{end + 1} = binary_mask_filled;

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
imwrite(total_image_perim, 'binary_mask_perim_1.tif', 'tif');
imwrite(total_image_filled, 'binary_mask_filled_1.tif', 'tif');



%% Read in Images
gt_image = imread("Ground Truth Image.tif");
test_image = imread("binary_mask_filled_1.tif");

%% Performance Analysis: Accuracy
diff_img = imabsdiff(gt_image, test_image);
num_pixels = numel(gt_image);
num_correct = num_pixels - nnz(diff_img);
accuracy = num_correct / num_pixels * 100;
disp(['Overlapped Image Accuracy: ', num2str(accuracy)])

% Sensitivity
true_positives = nnz(test_image & gt_image);
positives = nnz(gt_image);
sensitivity = true_positives / positives;
disp(['Sensitivity (%): ', num2str(sensitivity*100)])

% Specificity
true_negatives = nnz(~test_image & ~gt_image);
negatives = nnz(gt_image);
specificity = true_negatives / negatives;
disp(['Specificity (%): ', num2str(specificity)])

% F1
TP = nnz(test_image & gt_image);
FP = nnz(test_image & ~gt_image);
FN = nnz(~test_image & gt_image);

% Compute the precision and recall
precision = TP / (TP + FP);
recall = TP / (TP + FN);

% Compute the F1 score
f1_score = 2 * (precision * recall) / (precision + recall);
disp(['F1 score: ', num2str(f1_score)])

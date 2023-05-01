%% Performance Analysis
gt_image = imread("Ground Truth Image.tif"); % Change me to the file name and structure of your ground truth image
test_image = imread("binary_mask_filled_original.tif"); % Change me to the file name and structure of your nuclei mask image

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
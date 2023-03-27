% Load the ROIs
I = imread('roi2.tif');
figure, imagesc(I), axis image;


[a, ~, ~] = colour_deconvolution(I, 'HE 2'); % color deconvolution
figure, imagesc(a), axis image;% hematoxylin for nuclei

a_filterd = imgaussfilt(a,2); % gaussian filter
figure, imagesc(a_filterd), axis image

enhanced_img = imadjust(a_filterd); % image enhancement
figure, imagesc(enhanced_img), axis image

threshold = graythresh(enhanced_img); % global thresholding
binary_img = imbinarize(enhanced_img,threshold); binary_img = ~ binary_img; % binarize image
figure, imshow(binary_img);

se = strel('disk', 2); % morphorlogical transform/opening
eroded_img = imerode(binary_img, se);
dilated_img = imdilate(eroded_img, se);

%figure, imshow(dilated_img);

% Remove small noise
dilated_img = bwareaopen(dilated_img, 100); % Change 100 to the desired minimum area size
%figure, imshow(dilated_img);

overlay_img = imoverlay(I, bwperim(dilated_img), [.3 1 .3]); % overlay
figure, imagesc(overlay_img), axis image;

subplot(1,2,1);
imagesc(a), axis image;
subplot(1,2,2);
imshow(overlay_img); axis image
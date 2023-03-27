%% Loop and extract all ROIs
[filename, pathname] = uigetfile( ...
    {'*.tif*;*.png;*.jpg;*.svs;*.scn', 'All Image Files (*.tif*, *.png, *.jpg, *.svs, *.scn)';
    '*.tif*','TIFF images (*.tif, *.tiff)'; ...
    '*.png','PNG images (*.png)'; ...
    '*.jpg','JPG images (*.jpg)'; ...
    '*.svs','SVS images (*.svs)'; ...
    '*.scn','SCN images (*.scn)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick Image');

I1info=imfinfo([pathname filename]);
for i=1:numel(I1info),pageinfo1{i}=['Page ' num2str(i) ': ' num2str(I1info(i).Height) ' x ' num2str(I1info(i).Width)]; end
fprintf('done.\n');
fname=[pathname filename];
if numel(I1info)>1,
    [s,v]=listdlg('Name','Choose Level','PromptString','Select a page for Roi Discovery:','SelectionMode','single','ListSize',[170 120],'ListString',pageinfo1); drawnow;
    if ~v, guidata(hObject, handles); return; end
    fprintf('Reading page %g of image 1... ',s);
    io=imread(fname,s);
    fprintf('done.\n');
else
    fprintf('Image doesnt have any pages!\n');
end


figure,imshow(io)

[s2,v2]=listdlg('Name','Choose Level','PromptString','Select a page for ROI extraction:','SelectionMode','single','ListSize',[170 120],'ListString',pageinfo1); drawnow;
if ~v, guidata(hObject, handles); return; end

hratio=I1info(s2).Height/I1info(s).Height;
wratio=I1info(s2).Width/I1info(s).Width;

io_lowres=imread(fname,s2);

rectPos = [0 0 255/wratio 255/hratio]; %[xmin ymin width height]. Ratio for page2 (low resolution) and page 1 (high resolution)
h = imrect(gca, rectPos);
roi = wait(h);

% Set sliding window parameters
windowSize = 256;
stepSize = 256;

% Extract patches using sliding window
patchIdx = 0;
for y = 1:stepSize:size(io_lowres, 1)-windowSize+1
    for x = 1:stepSize:size(io_lowres, 2)-windowSize+1
        patchIdx = patchIdx + 1;
        patch_lowres = io_lowres(y:y+windowSize-1, x:x+windowSize-1,:);
        
        % Save patch as image file
        imwrite(patch_lowres, sprintf('patch_%d.png', patchIdx));
    end
end

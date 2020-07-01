%% This function makes a Heatmap figure
% Built for eye-tracking data visualization

% INPUTS
% 1. data - The duration data used to plot the Heatmap. This should be a
%         Matrix representing the screen. Each cell contains the time spent 
%         fixating in this location. The number of cells does not matter. It
%         depends on the resolution you want.
% 2. image - The image to diaplay underneath.
% 3. imagePosition - Where the image was presented on the screen. In pixels
%                    [origin_X, Origin_Y, size_X, size_Y].
% 4. trialFlag - Indicator vertor (1/0) for the trials that you want to
%                include in the Heatmap calculation. For instance if you only want to
%                create on plot for each condition.
% 5. minClip - Threshold, in ms, for minimum values to plot. E.g. if set to 50,
%         only locations with more than 50ms total fixation time will
%         be colored, anything bellow will be set to 0 (white/transparent).
% 6. screenXsize - the size of the screen that was used to present stimuli
%                 in Pixels (X = width).
% 7. screenYsize - Height of screen
% 8. title - The title of your Figure.

%%
function do_heatmap(eyeData, xBin, yBin, myImage, imagePosition, trialFlag, minClip, screenXsize, screenYsize, myTitle)


%% Do the Total fixation duration per spatial bin calculation

% Declare zeros Matrix of (X res/Bin width) rows by (Y res/Bin height) Col
nRows = screenYsize/yBin;
nCols = screenXsize/xBin;

% Set the duration matrix to 0 all around to begin
allDurMatrix = zeros(nRows,nCols);
durationMatrix = zeros(nRows,nCols);

% For each bin (defined by the [i,j] of the Zeros Matrix)
% Define the "pixel" (resized according to the number/size of bins coordinate (i-1)*binWith, (j-1)*binHeight, 1*binWith,
% j*binHeight.

% Then loop trought all the fixations.
% If x.y of fix within search bin then add the duration of that fix to the
% value inside the i,j cell of the Time Matrix.
for j = 1 : size(durationMatrix,1)
    for i = 1 : size(durationMatrix,2)
       
        searchBin = [(i-1)*xBin, (j-1)*yBin, i*xBin, j*yBin];
   
        for k = trialFlag
            if isempty(eyeData.TrialFix{1,k})
                continue
            else
                for kk = size(eyeData.TrialFix{1,k},2)
                    fixX = eyeData.TrialFix{1,k}(2,kk); % X coordinate of this fixation
                    fixY = eyeData.TrialFix{1,k}(3,kk); % Y coordinate of this fixation
                    % If coordinate are within the Bin then add the duration
                    % of the fixation to the total of this bin.
                    if fixX >= searchBin(1) && fixY >= searchBin(2) && fixX < searchBin(3) && fixY < searchBin(4)
                      durationMatrix(j,i) = durationMatrix(j,i) + eyeData.TrialFix{1,k}(4,kk);
                    end
                end
            end
        end
        
    end
end

allDurMatrix = allDurMatrix + durationMatrix;


%% Do the Figure
figure
% fribble stimulus
image([imagePosition(1), imagePosition(3)],[imagePosition(2), imagePosition(4)], myImage);

hold on

% Smooth heatmap
figData = allDurMatrix;
%// Define integer grid of coordinates for the above data
[X,Y] = meshgrid(1:size(figData,2), 1:size(figData,1));
%// Define a finer grid of points
[X2,Y2] = meshgrid(1:(1/xBin):size(figData,2), 1:(1/yBin):size(figData,1));
%// Interpolate the data and show the output
outData = interp2(X, Y, figData, X2, Y2, 'linear');
outData(outData == 0) = NaN;

% The clims minimum affects the treshold at which value sill appeat white 
% in the heatmap (if not defined, only the cells with 0 will appear white).
maxi = max(outData(:));
clims = [minClip,maxi];

% THIS LINE PLOTS THE ACUTAL HEATMAP
him = imagesc(outData,clims);

% Makes it so that all the cells of value 0 (or the minimum set by clim)
% appear white.
mycolormap = [ones(1,3); jet(30)];
colormap(mycolormap);
% Make HEATMAP somewhat transparent so we can see the image diplayed underneath.
% Change the value after 'AlphaData' to make it more/less transparent
set(him,'AlphaData',0.4);
xlim([0 screenXsize]);
ylim([0 screenYsize]);
title(myTitle);



end
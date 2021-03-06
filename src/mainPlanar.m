clear all;

%Get list of all files
imDir = '../images';
imScene = getAllFiles(imDir);
N = numel(imScene);
outDir = '../output';
%Reading the images in the directory
for i = 1: N,
    imageArray{i} = imread(imScene{i});
end
%% Extract features for all images
[features, points] = extractFeaturesFromScene(imageArray);

%% Find matches between all pairs of images
% And compute homography

adjacency = zeros(N, N);
H = cell(1, N);

%Initialize transform estimator
gte = vision.GeometricTransformEstimator('Transform', 'Projective',...
    'NumRandomSamplingsMethod','Desired confidence','DesiredConfidence',80);%, 'InlierPercentageSource', 60

%for all pairs of images..
for i = 1 : N - 1,
    for j = i + 1 : N,
        %Find matches
        matchedIndexPairs = matchFeatures(features{i},features{j});
        
        %Skip iteration if less than 50 points matched
        if numel(matchedIndexPairs) < 50,
            continue
        end
        matchedPoints1 = points{i}(matchedIndexPairs(:,1));
        matchedPoints2 = points{j}(matchedIndexPairs(:,2));
        %Estimate homography
%         [tform1, inlierIdx] = step(gte, matchedPoints2.Location, matchedPoints1.Location);
        [tform2, inlierIdx] = step(gte, matchedPoints1.Location, matchedPoints2.Location);
        %If at least 50% inliers found, save homography
%                 if sum(inlierIdx == 1) / length(matchedIndexPairs) >= 0.5,
%         H{j}{i} = tform1;
        H{i}{j} = tform2;
        %update adjacency matrix
        adjacency(i, j) = 1;
        %         end     
%                 end
    end
end
%% Compute panorama for i-th group of images
i = 1;
groups = findClusters(adjacency);
G = groups{i};
I_group = {};
for k = 1: numel(G),
    I_group{G(k)} = imageArray{G(k)};
end
% pairs = pairsFromAdjacency(G, adjacency);
pan = imagesToPanorama(H, G, I_group, adjacency);
figure(), imshow(pan);
function [bbox bb] = computeBbox(I_array, H_array)
n = numel(I_array);

for i = 1: n,
    [m,n,l] = size(I_array{i});
    y = H_array{i}*[[1;1;1], [1;m;1], [n;m;1] [n;1;1]];
    y(1,:) = y(1,:)./y(3,:);
    y(2,:) = y(2,:)./y(3,:);
    bb(:,i) = [
        ceil(min(y(1,:)));
        ceil(max(y(1,:)));
        ceil(min(y(2,:)));
        ceil(max(y(2,:)));
        ];
end

bbox = [min(bb(1,:)) max(bb(2,:)) min(bb(3,:)) max(bb(4,:))];
%% Will potentially be used to clean EyeTracking data...


% Clean Data: Remove too ong or short Fixations (Inhoff & Radach, 1998)
shortIndex = find(data1(:,3) <= 50); % Shorter than 50ms
data1(shortIndex,:) = [];
longIndex = find(data1(:,3) >= 1200); % Longer than 1200ms
data1(longIndex,:) = [];
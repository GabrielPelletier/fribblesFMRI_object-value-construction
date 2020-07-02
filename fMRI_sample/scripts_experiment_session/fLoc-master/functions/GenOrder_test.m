%% Script to create counterbalanced lists (runs)
% to present conditions in counterbalanced order accross runs.


runs = 4;

% C num of conditions repeated n times
C = 4;
N = 3;

%% Create 1 list per run of the conditions * N repeats
% in Random order
listMat = zeros(C*N,runs);
for i = 1:runs
    list = [];
    for j = 1 : C
       list = [list,repmat(j,1,N)]; 
    end
    list = list(randperm(length(list)));
    listMat(:,i) = list';
end

%% Check if runs are counterbalanced

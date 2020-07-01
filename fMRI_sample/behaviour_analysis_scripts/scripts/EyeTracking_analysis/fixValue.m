load('25_fmri_RatingTask_Run4.mat')

    for i = 1 : length(ratingData)
        if ratingData{i,5} == 63
            ratingData{i,5} = 90;
        end
    end

save('25_fmri_RatingTask_Run4.mat', 'ratingData');


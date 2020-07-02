function [bonusMoney, auctionsWon, totBids, buyValue] = auctionResolve(subjectNumber, numRuns)

%% Auctions winning and selling parameters
bidMargin = -5; % If the bid was the real average price + bidMargin then the item is won.
profitMargin = 1.30; % We buy each won item for its real average price + margin (1.15 = 15%).
bonusMin = 0;
bonusMax = 10;

%% Load data
dataDir = [pwd,'/Output/',num2str(subjectNumber),'/'];

% load data
    fullSubData = [];
    for r = 1 : numRuns
    load([dataDir,num2str(subjectNumber),'_fmri_RatingTask_Run',num2str(r),'.mat']);
    fullSubData = [fullSubData;ratingData];
    end
    
% Extract Only Trials that were evaluated
    ratingInd = find(strcmp(fullSubData(:,4),'bid'));
    ratingTrialsData = {};
    for i = 1 : length(ratingInd)
        ratingTrialsData(end+1,1:6) = fullSubData(ratingInd(i)-1, 1:6);
        ratingTrialsData(end,7:9) = fullSubData(ratingInd(i), 7:9);
    end

% Convert cell to number matrix (bid amount, Items value, Won or not)
auctionData = [cell2mat(ratingTrialsData(:,7)),cell2mat(ratingTrialsData(:,5))];

% Determine if each auction was won or not

for i = 1:length(auctionData)
    if auctionData(i,1) >= (auctionData(i,2) + bidMargin)
        auctionData(i,3) = 1; % Auction Won
    elseif auctionData(i,1) < (auctionData(i,2) + bidMargin)
        auctionData(i,3) = 0; % Auction loss
    else
        auctionData(i,3) = 999; % Should not happen
    end
end

% Number of auctions won
auctionsWon = sum(auctionData(:,3));
% Get the index of wins
indAuctionsWon = find(auctionData(:,3)==1);

% Get the Total Value of won bids
totBids = sum(auctionData(indAuctionsWon, 1));

% Calculate the value we Buy the subjects' inventory for (based on margin)
buyValue = sum(auctionData(indAuctionsWon, 2))*profitMargin;

% Get net profit (What they paid - What we bought it for)
netProfit = buyValue - totBids;

%% Calculate bonus money

% What's the best they could have made? (based on set bids and profit
% margins)
maxBuyValue = sum(auctionData(:,2)) * profitMargin; % If they had won all auctions
for i = 1:length(auctionData)
    auctionData(i,4) = auctionData(i,2) + bidMargin; 
end
%minBidValue = sum(auctionData(:,2));% If they had paid the minimum for all of them.
minBidValue = sum(auctionData(:,4));% If they had paid the minimum for all of them.
maxNetProfit = maxBuyValue - minBidValue;

% Based on min max bonus range compare to min-max netProfit range
if netProfit < 0 
    bonusMoney = bonusMin;
else 
    bonusMoney = (bonusMax * netProfit) / maxNetProfit;
end

% Round value to upper Integer
bonusMoney = ceil(bonusMoney);

if bonusMax < bonusMoney
    bonusMoney = bonusMax;
end
    

%% Display the results in a messsage BOX
line1 = ['Number of auctions won:  ',num2str(auctionsWon)];
line2 = ['Your bonus is worth:  ₪',num2str(bonusMoney)];

h = msgbox({line1, '' ,line2, ''},'Auctions Results');
set(h, 'position', [400 400 475 250]); %makes box bigger
ah = get( h, 'CurrentAxes' );
ch = get( ah, 'Children' );
set( ch, 'FontSize', 35 ); %makes text bigger

end
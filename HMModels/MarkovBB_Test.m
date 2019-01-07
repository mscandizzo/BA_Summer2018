%%Loading variable information
load('bloomberg_data.mat');
%% Defining the Portfolio Problem (with transaction costs)
Price = [asset_cell_array(1), asset_cell_array(2), asset_cell_array(3), asset_cell_array(4), asset_cell_array(5), asset_cell_array(6), asset_cell_array(7)];
PriceTT = synchronize(asset_cell_array{1,1}, asset_cell_array{1,2}, asset_cell_array{1,3}, asset_cell_array{1,4}, asset_cell_array{1,5}, asset_cell_array{1,6}, asset_cell_array{1,7},'union','linear');

% Extract Index level data for each va riable
Cash_Index = PriceTT.LAST_PRICE_1;
Bond_Index = PriceTT.LAST_PRICE_2;
Equity_Index = PriceTT.LAST_PRICE_3;
TedSpread = PriceTT.LAST_PRICE_4;
ECSU_Index = PriceTT.LAST_PRICE_5;
UST10Y = PriceTT.LAST_PRICE_6;
UST3M = PriceTT.LAST_PRICE_7;

% Calculate Slope of UST Curve
Carry  = (UST10Y - UST3M)/100;
% 
% Calculate UST Volatility
% expDecay = 0.97;
% tewma = floor(2/(1-expDecay) - 1);
% couponlag = 45; % Coupon rate approximated by a moving average ofg the yield
% calcbonds = tsmovavg(UST10Y, 's', couponlag, 1).*100.*(1-(1+US10Y./100).^(-10))./UST10Y+100.*(1+UST10Y./100).^(-10);
% squaredRet = returns(calcbonds(couponlag:end)).^2;
% bondRetEWMA = tsmovavg(squaredRet, 'e', tewma, 1);
% annualBondStdDev = sqrt(250.*bondRetEWMA(65:end)); % annualized realized volatility, cutting first 65 NAN values
% 
% CarryToRisk = carry(couponLag+65:end)./annualBondStdDev;

% Calculate Returns
Cash_Return = Cash_Index(1:end-1)./252;
Bond_Return = tick2ret(Bond_Index);
Equity_Return = tick2ret(Equity_Index);

X = [TedSpread, Carry, ECSU_Index];
Y = [Cash_Return, Bond_Return, Equity_Return];
%% Regime Switching Model
tic
dep = Y(:,1:3);                       % Defining dependent variables in system
constVec = ones(length(dep),1);       
indep{1} = constVec;                  
indep{2} = constVec;                  
indep{3} = constVec;                  

k = 2;                               % Number of States
S{1} = [1 1];                        % Defining which parts of the equation will switch states (column 1 and variance only)
S{2} = [1 1];                       
S{3} = [1 1]; 

advOpt.distrib = 'Normal';            % The Distribution assumption ('Normal', 't' or 'GED')
advOpt.std_method = 1;                % Defining the method for calculation of standard errors. See pdf file for more details
advOpt.diagCovMat = 0;

 [Spec_Out] = MS_Regress_Fit(dep,indep,k,S,advOpt); % Estimating the model
toc
%% Extraction of the Markov Model

[meanFor,stdFor]=MS_Regress_For(Spec_Out);

filProb = Spec_Out.filtProb; %Extract Filtered Probability
CovMat = Spec_Out.Coeff.covMat; %Extract Covariance Matrix
Asset = { 'Cash', 'Bonds', 'Stocks'};

% Extract Mean Returns
MeanMat{1} = [Spec_Out.Coeff.S_Param{1,1}(1,1); Spec_Out.Coeff.S_Param{1,1}(1,2)];
MeanMat{2} = [Spec_Out.Coeff.S_Param{1,2}(1,1); Spec_Out.Coeff.S_Param{1,2}(1,2)];
MeanMat{3} = [Spec_Out.Coeff.S_Param{1,3}(1,1); Spec_Out.Coeff.S_Param{1,3}(1,2)];

%% Setting up the Porfolio
TargetRisk = 0.0024; %Set up the target risk

%Creating Porfolio
p1 = Portfolio('Name', 'Asset Allocation Portfolio', 'AssetList', Asset);
p1 = setDefaultConstraints(p1);
p1 = setGroups(p1, [ 0, 1, 1], [], 0.85); %Equity allocation is no more than 85% of the portfolio.
p2 = p1;


filProb = Spec_Out.filtProb; %Extract Filtered Probability
CovMat = Spec_Out.Coeff.covMat; %Extract Covariance Matrix

% Set up mean returns and covariance matrices for different states
p1 = setAssetMoments(p1, MeanMat{1}, CovMat{1});
p2 = setAssetMoments(p1, MeanMat{2}, CovMat{2});


disp(MeanMat);

%% Calculate the weighted average weights and risk returns for each time period

for i = 1:length(filProb)
    % Calculate the optimized weights for each state
    p1wgt = estimateFrontierByRisk(p1, TargetRisk);
    p2wgt = estimateFrontierByRisk(p2, TargetRisk);
    
    
    %Calculate the weighted average weights
    pwgt{i} = [p1wgt p2wgt] * filProb(i, :)';
    
    %Rebalance portfolio
    p1 = Portfolio('Name', 'Asset Allocation Portfolio', 'AssetList', Asset,'InitPort', pwgt{i});
    p1 = setDefaultConstraints(p1);
    p1 = setGroups(p1, [ 0, 1, 1], [], 0.85);
    p2 = p1;


    p1 = setAssetMoments(p1, MeanMat{1}, CovMat{1});
    p2 = setAssetMoments(p2, MeanMat{2}, CovMat{2});
end
%% Plot Weightings over time
figure
WgtMat = pwgt{1}';
for i = 1: length(filProb)-1;
    WgtMat = [WgtMat; pwgt{i+1}'];
end
area(WgtMat);
% Add a legend
legend(Asset, 'Location', 'Best')

% Add title and axis labels
title('Portfolio weights')
xlabel('Time')
axis([1 35 0 1])


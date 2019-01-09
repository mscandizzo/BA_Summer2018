%% Modeling the United States Economy
%
% Economists and policymakers are concerned with understanding the dynamics of economies, especially
% during periods of significant macroeconomic shocks. Although numerous approaches are possible, we
% will develop a small macroeconomic model in the style of Smets and Wouters.
%Â
% Our descriptive macroeconomic model offers a nice starting point to examine the impact of various
% shocks on the United States economy, particularly around the period of the 2008 fiscal crisis. We
% will use the multiple time series tools from the Econometrics Toolbox(TM) to gain some insight.

% Copyright 2009-2014 The MathWorks, Inc.

%% Description of the Model
%
% The Smets-Wouters model (2002, 2004, 2007) is a nonlinear system of equations in the form of a
% Dynamic Stochastic General Equilibrium (DSGE) model that seeks to characterize an economy derived
% from economic first principles. The basic model works with 7 time series: output, prices, wages,
% hours worked, interest rates, consumption, and investment.
%
% Whereas a common approach in macroeconomics has been to create "large" empirically-motivated
% regression models, the DSGE approach focuses on "small" theoretically-derived models. It is this
% combination of normative rigor and parsimony that is one of the main attractions of the DSGE
% approach.
%
% Armed with a small model of this sort, the linearized form can be cast as a VAR model that can be
% handled with standard methods of multiple time series analysis. It is an unrestricted form of this
% VAR model that we will examine subsequently.
%
% For illustrative purposes, we will add an eighth time series: unemployment. Although this is not a
% part of the basic model (and is actually superfluous within the Smets-Wouters framework),
% unemployment tracks a widely-perceived measure of the "health" of an economy.
%
% Whereas the original model was developed to model both country and aggregate European economies,
% we will apply the model to the United States economy as in Smets and Wouters (2007).

%% Obtain Economic Data from St. Louis Federal Reserve
%
% If you have the Datafeed Toolbox(TM) and are online, this example will download data from the St.
% Louis Federal Reserve Economic Database (see link to FRED in the references) so that the analysis
% will incorporate the most recent available data. If not, this example will load data from the file
% |Data_USEconModel.mat| which contains time series for the period from 31-Mar-1947 to 31-Mar-2009.
% The series are listed in the following table.

% FRED Series     Description
% -----------     ----------------------------------------------------------------
% COE             Paid compensation of employees in $ billions
% CPIAUCSL        Consumer price index
% FEDFUNDS        Effective federal funds rate
% GCE             Government consumption expenditures and investment in $ billions
% GDP             Gross domestic product in $ billions
% GDPDEF          Gross domestic product price deflator
% GPDI            Gross private domestic investment in $ billions
% GS10            Ten-year treasury bond yield
% HOANBS          Non-farm business sector index of hours worked
% M1SL            M1 money supply (narrow money)
% M2SL            M2 money supply (broad money)
% PCEC            Personal consumption expenditures in $ billions
% TB3MS           Three-month treasury bill yield
% UNRATE          Unemployment rate

%%
%
% Since the data from FRED have different periodicities and date ranges, we use the financial time
% series tools to build a universe of our time series at a quarterly periodicity.

%%
tic
if  license('test', 'datafeed_toolbox')

	% Load data from FRED and convert to quarterly periodicity
	% Note that dates are start-of-period dates in the FRED database
	
	fprintf('Loading time series data from St. Louis Federal Reserve (FRED) ...\n');
	
	% FRED time series to be used for our analysis
	
	series = { 'COE', 'CPIAUCSL', 'FEDFUNDS', 'GCE', 'GDP', 'GDPDEF', 'GPDI', ...
		'GS10', 'HOANBS', 'M1SL', 'M2SL', 'PCEC', 'TB3MS', 'UNRATE' };

	% Obtain data with "try-catch" and load Data_USEconModel.mat if problems occur
	
	try
		Universe = [];

		% Open a Datafeed Toolbox connection to FRED
		
		c = fred('https://research.stlouisfed.org/fred2/');
        
		for i = 1:numel(series)
            
			fprintf('Started loading %s ... ',series{i});

			% Fetch data from FRED
			
			FredData = fetch(c, series{i});

			% Dates are start-of-period dates so move to end-of-period date
			
			offset = 1;
			if strcmpi(strtrim(FredData.Frequency),'Quarterly')
				offset = 2;
			elseif strncmp('Mar', strtrim(FredData.Frequency), 3)
				offset = 2;
			else
				offset = 0;
			end

			% Set up dates
			
			dates = FredData.Data(:,1);

			mm = month(dates) + offset;
			yy = year(dates);
			for t = 1:numel(dates)
				if mm(t) > 12
					mm(t) = mm(t) - 12;
					yy(t) = yy(t) + 1;
				end
			end
			dates = lbusdate(yy, mm);
			
			% Set up data
			
			Data = FredData.Data(:,2);

			% Create financial time series
			
			fts = fints(dates, Data, series{i});
			
			% Convert to quarterly periodicity
			
			if strcmpi(strtrim(FredData.Frequency), 'Quarterly')
				fprintf('Quarterly ... ');
			elseif strncmp('Mar', strtrim(FredData.Frequency), 3)
				fprintf('Quarterly ... ');
			else
				fprintf('Monthly ... ');
				fts = toquarterly(fts);
			end

			% Combine time series
			
			Universe = merge(fts, Universe);

			fprintf('Finished loading %s ...\n',series{i});
            
		end
        
		close(c);
		
		Universe.desc = 'U.S. Macroeconomic Data';
		Universe.freq = 'quarterly';

		% Trim date range to period from 1947 to present
		
		StartDate = datenum('31-Mar-1947');
		EndDate = datenum(Universe.dates(end));

		Universe = Universe([datestr(StartDate,1) '::' datestr(EndDate,1)]);
		
		% Convert combined time series into date and data arrays
		
		dates = Universe.dates;
		Data = fts2mat(Universe.(series));
		DataTable = array2table(Data,'VariableNames',series,'RowNames',cellstr(datestr(dates,'QQ-YY')));
        
		% Uncomment next line to save data in Data_USEconModelUpdate.mat
		
		% save Data_USEconModelUpdate series dates Data DataTbl
        
	catch E
		
		% Case with no internet connection
		
		fprintf('Unable to connect to FRED. Will use local data.\n');
		fprintf('Loading data from Data_USEconModel.mat ...\n');
		load Data_USEconModel
        
	end
    
else
	
	% Case with no Datafeed Toolbox
	
	fprintf('Loading data from Data_USEconModel.mat ...\n');
	load Data_USEconModel
    
end

%% Business Cycle Dates from National Bureau of Economic Research
%
% To examine the interplay between the business cycle and our model, we also include the dates for
% peaks and troughs of the economic cycle from the National Bureau of Economic Research (see link to
% NBER in the references). We arbitrarily set the middle of the listed month as the start or end
% date of a recession.

Recessions = [ datenum('15-May-1937'), datenum('15-Jun-1938');
	datenum('15-Feb-1945'), datenum('15-Oct-1945');
	datenum('15-Nov-1948'), datenum('15-Oct-1949');
	datenum('15-Jul-1953'), datenum('15-May-1954');
	datenum('15-Aug-1957'), datenum('15-Apr-1958');
	datenum('15-Apr-1960'), datenum('15-Feb-1961');
	datenum('15-Dec-1969'), datenum('15-Nov-1970');
	datenum('15-Nov-1973'), datenum('15-Mar-1975');
	datenum('15-Jan-1980'), datenum('15-Jul-1980');
	datenum('15-Jul-1981'), datenum('15-Nov-1982');
	datenum('15-Jul-1990'), datenum('15-Mar-1991');
	datenum('15-Mar-2001'), datenum('15-Nov-2001');
	datenum('15-Dec-2007'), datenum('15-Jun-2009') ];

Recessions = busdate(Recessions);

%% Transform Raw Data into Time Series for the Model
%
% To work with our time series, we create two sets of time series. The first set contains
% differenced or rate data for each of our time series and the second set contains integrated or
% cumulative data. Time series that have exponential growth are also transformed into logarithmic
% series prior to differencing.

% Remove dates with NaN values

ii = any(isnan(Data),2);
dates(ii) = [];
Data(ii,:) = [];
DataTable(ii,:) = [];

% Log series

CONS = log(DataTable.PCEC);
CPI = log(DataTable.CPIAUCSL);
DEF = log(DataTable.GDPDEF);
GCE = log(DataTable.GCE);
GDP = log(DataTable.GDP);
HOURS = log(DataTable.HOANBS);
INV = log(DataTable.GPDI);
M1 = log(DataTable.M1SL);
M2 = log(DataTable.M2SL);
WAGES = log(DataTable.COE);

% Interest rates (annual)

rFED = 0.01*(DataTable.FEDFUNDS);
rG10 = 0.01*(DataTable.GS10);
rTB3 = 0.01*(DataTable.TB3MS);

% Integrated rates

FED = ret2tick(0.25*rFED);
FED = log(FED(2:end));
G10 = ret2tick(0.25*rG10);
G10 = log(G10(2:end));
TB3 = ret2tick(0.25*rTB3);
TB3 = log(TB3(2:end));

% Unemployment rate

rUNEMP = 0.01*(DataTable.UNRATE);

UNEMP = ret2tick(0.25*rUNEMP);
UNEMP = log(UNEMP(2:end));

% Annualized rates

rCONS = [ 4*mean(diff(CONS(1:5))); 4*diff(CONS) ];
rCPI = [ 4*mean(diff(CPI(1:5))); 4*diff(CPI) ];
rDEF = [ 4*mean(diff(DEF(1:5))); 4*diff(DEF) ];
rGCE = [ 4*mean(diff(GCE(1:5))); 4*diff(GCE) ];
rGDP = [ 4*mean(diff(GDP(1:5))); 4*diff(GDP) ];
rHOURS = [ 4*mean(diff(HOURS(1:5))); 4*diff(HOURS) ];
rINV = [ 4*mean(diff(INV(1:5))); 4*diff(INV) ];
rM1 = [ 4*mean(diff(M1(1:5))); 4*diff(M1) ];
rM2 = [ 4*mean(diff(M2(1:5))); 4*diff(M2) ];
rWAGES = [ 4*mean(diff(WAGES(1:5))); 4*diff(WAGES) ];

%% Display Raw Data
%
% To see what our time series look like, we plot each of the differenced time series (identified
% with a lowercase r preceding the series mnemonic) and overlay shaded bands that identify periods
% of economic recession as determined by NBER.

%clf;
figure 

subplot(3,2,1,'align');
plot(dates, [rGDP, rINV]);
recessionplot;
dateaxis('x');
title('\bfInvestment and Output');
h = legend('GDP','INV','Location','Best');
h.FontSize = 7;
h.Box = 'off';
axis([dates(1) - 600, dates(end) + 600, 0, 1]);
axis 'auto y'

subplot(3,2,2,'align');
plot(dates, [rCPI, rDEF]);
recessionplot;
dateaxis('x');
title('\bfInflation and GDP Deflator');
h = legend('CPI','DEF','Location','Best');
h.FontSize = 7;
h.Box = 'off';
axis([dates(1) - 600, dates(end) + 600, 0, 1]);
axis 'auto y'

subplot(3,2,3,'align');
plot(dates, [rWAGES, rHOURS]);
recessionplot;
dateaxis('x');
title('\bfWages and Hours');
h = legend('WAGES','HOURS','Location','Best');
h.FontSize = 7; 
h.Box = 'off';
axis([dates(1) - 600, dates(end) + 600, 0, 1]);
axis 'auto y'

subplot(3,2,4,'align');
plot(dates, [rCONS, rGCE]);
recessionplot;
dateaxis('x');
title('\bfConsumption');
h = legend('CONS','GCE','Location','Best');
h.FontSize = 7;
h.Box = 'off';
axis([dates(1) - 600, dates(end) + 600, 0, 1]);
axis 'auto y'

subplot(3,2,5,'align');
plot(dates, [rFED, rG10, rTB3]);
recessionplot;
dateaxis('x');
title('\bfInterest Rates');
h = legend('FED','G10','TB3','Location','Best');
h.FontSize = 7;
h.Box = 'off';
axis([dates(1) - 600, dates(end) + 600, 0, 1]);
axis 'auto y'

subplot(3,2,6,'align');
plot(dates, rUNEMP);
recessionplot;
dateaxis('x');
title('\bfUnemployment');
h = legend('UNEMP','Location','Best');
h.FontSize = 7;
h.Box = 'off';
axis([dates(1) - 600, dates(end) + 600, 0, 1]);
axis 'auto y'

%%
% The shaded bands to identify recessions are plotted using the utility function |recessionplot|.

%% Set up the Main Model
%
% The main model for our analysis uses the seven time series described in Smets and Wouters (2007)
% plus an appended eighth time series. These time series are listed in the following table with
% their relationship to raw FRED counterparts. The variable Y contains the main time series for the
% model and the variable iY contains integrated data from Y that will be used in forecasting
% analyses.

%   Model       FRED Series     Transformation from FRED Data to Model Time Series
%   --------    -----------     --------------------------------------------------
%   rGDP        GDP             rGDP = diff(log(GDP))
%   rDEF        GDPDEF          rDEF = diff(log(GDPDEF))
%   rWAGES      COE             rWAGE = diff(log(COE))
%   rHOURS      HOANBS          rWORK = diff(log(WORK))
%   rTB3        TB3MS           rTB3 = 0.01*TB3MS
%   rCONS       PCEC            rCONS = diff(log(PCEC))
%   rINV        GPDI            rINV = diff(log(GPDI))
%   rUNEMP      UNRATE          rUNEMP = 0.01*UNRATE

Y = [rGDP, rDEF, rWAGES, rHOURS, rTB3, rCONS, rINV, rUNEMP];
iY = [GDP, DEF, WAGES, HOURS, TB3, CONS, INV, UNEMP];

YSeries = {'Output (GDP)', 'Prices', 'Total Wages', 'Hours Worked', ...
	'Cash Rate', 'Consumption', 'Private Investment', 'Unemployment'};
YAbbrev = {'GDP', 'DEF', 'WAGES', 'HOURS', 'TB3', 'CONS', 'INV', 'UNEMP'};

YInfo = 'U.S. Macroeconomic Model';

n = numel(YSeries);

fprintf('The date range for available data is %s to %s.\n', ...
	datestr(dates(1),1),datestr(dates(end),1));

%% Main Model
%
% The main model is an unrestricted VAR model in the form
%
% $$
% \textbf{Y}_t = \textbf{a} + \sum_{i = 1}^p \textbf{A}_i \textbf{Y}_{t - i} + \textbf{W}_t
% $$

%%
% with

%%
% $$
% \textbf{Y}_t = \left[ \begin{array}{c}
% rGDP_t \\
% rDEF_t \\
% rWAGES_t \\
% rHOURS_t \\
% rTB3_t \\
% rCONS_t \\
% rINV_t \\
% rUNEMP_t \\
% \end{array} \right]
% $$

%%
% and

%%
% $$
% \textbf{W}_t \sim N(\textbf{0}, \textbf{Q}) .
% $$

%%
% Some differences between the data for our model and the Smets-Wouters model should be noted.
% First, we use nominal series throughout since the GDP deflator is part of our model. Second, we
% use the 3-month Treasury Bill rate in place of the Federal Funds rate due to greater coverage.
% Third, we use the change in hours worked rather than the integrated series. Fourth, of course, we
% have added unemployment. Finally, we do not detrend the data with either series trends or a common
% GDP trend.

%% Optimal Lag Order
%
% The first step in our analysis is to determine the "optimal" number of autoregressive lags based
% on the Akaike Information Criterion (AIC). We set up models with up to 7 lags (7 quarters) and
% perform the AIC test using the toolbox function |aicbic|. The minimum AIC test statistic
% identifies the optimal number of lags. Depending upon the source, the theory would suggest that 3
% lags are sufficient and practice dictates between 2 and 4 lags. We will use 2 lags subsequently.

nARmax = 7;

Y0 = Y(1:nARmax,:);
Y1 = Y(nARmax+1:end,:);

AICtest = zeros(nARmax,1);
for i = 1:nARmax
	Spec = vgxset('n', n, 'Constant', true, 'nAR', i, 'Series', YSeries);
	[Spec, SpecStd, LLF] = vgxvarx(Spec, Y1, [], Y0);
	AICtest(i) = aicbic(LLF,Spec.NumActive,Spec.T);
	fprintf('AIC(%d) = %g\n',i,AICtest(i));
end
[AICmin, nAR] = min(AICtest);

fprintf('Optimal lag for model is %d.\n',nAR);

%clf;
figure

plot(AICtest);
hold on
scatter(nAR,AICmin,'filled','b');
title('\bfOptimal Lag Order with Akaike Information Criterion');
xlabel('Lag Order');
ylabel('AIC');
hold off

%% Backtest to Assess Forecast Accuracy of the Model
%
% The next step is to determine the forecast accuracy of our model. To do this, we perform a
% Monte-Carlo simulation with 500 sample paths for each year from 1975 to the most recent prior
% year. Given 500 sample paths for each year, we estimate the root mean-square error (RMSE) between
% subsequent realizations and forecasts over the time horizon. For this analysis, the forecast
% horizon is 1 year.
%
% The RMSE forecasts work with integrated simulated forecast data to compute forecast accuracy
% because integrated forecasts provides a better measure of where the model is going than to work
% with differenced data.
%
% The results appear in the following table. Each row contains results for the end date of the
% estimation period which is also the start date for the forecast period. Following the date, each
% row contains the forecast RMSE for each series over the forecast horizon.

nAR = 2;

syy = 1975;                 % start year for backtest
eyy = 2008;                 % end year for backtest

Horizon = 4;                % number of quarters for forecast horizon

[T, n] = size(Y);

FError = NaN(eyy - syy + 1, n);
FDates = zeros(eyy - syy + 1, 1);

fprintf('RMSE of Actual vs Model Forecast (x 100) with Horizon of %d Quarters\n',Horizon);
fprintf('%12s','ForecastDate');
for i = 1:n
	fprintf('  %7s',YAbbrev{i});
end
fprintf('\n');

for yy = syy:eyy
	
	StartDate = lbusdate(1959,3);
	EndDate = lbusdate(yy,12);

	if StartDate < dates(1)
		error(message('econ:Demo_USEconModel:EarlyStartDate', datestr( dates( 1 ), 1 )));
	end
	if EndDate > dates(end)
		error(message('econ:Demo_USEconModel:LateStartDate', datestr( dates( end ), 1 )));
	end

	% Locate indexes in data for specified date range

	iStart = find(StartDate <= dates,1);
	if iStart < 1
		iStart = 1;
	end
	iEnd = find(EndDate <= dates,1);
	if iEnd > numel(dates)
		iEnd = numel(dates);
	end

	if iStart > 1
		Y0 = Y(1:iStart-1,:);
	else
		Y0 = [];
	end
	Y1 = Y(iStart:iEnd,:);
	iY1 = iY(iStart:iEnd,:);

	% Set up model and estimate coefficients

	Spec = vgxset('n', n, 'Constant', true, 'nAR', nAR, 'Series', YSeries, 'Info', YInfo);
	Spec = vgxvarx(Spec, Y1, [], Y0);
	
	% Do forecasts

	NumPaths = 500;
	iFY = vgxsim(Spec, Horizon, [], Y1, [], NumPaths);
	iFY = repmat(iY1(end,:),[Horizon,1,NumPaths]) + 0.25*cumsum(iFY);
	eFY = mean(iFY,3);

	% Assess Forecast Quality

	Ow = max(0,min(Horizon,(size(Y,1) - iEnd)));		% overlap between actual and forecast data

	if Ow >= Horizon
		h = Horizon;
	else
		h = [];
	end

	FDates(yy-syy+1) = lbusdate(yy,12);
	if ~isempty(h)
		Yerr = iY(iEnd+1:iEnd+Ow,:) - eFY(1:Ow,:);

		Ym2 = Yerr(1:h,:) .^ 2;
		Yrmse = sqrt(mean(Ym2,1));
		
		fprintf('%12s',datestr(EndDate,1));
		for i = 1:n
			fprintf('  %7.2f',100*Yrmse(i));
		end
		FError(yy-syy+1,:) = 100*Yrmse';
		fprintf('\n');
	end
end

%% Assess Forecast Accuracy
%
% The forecast errors are visualized in the following plot. On each subplot, the blue line plots the
% average of the RMSE forecast errors associated with each date along with the sample mean (green
% line) and standard deviation (dotted red lines) of these errors over all dates. A value of 1 on
% the plot corresponds with a 1% forecast error.
%
% Note that the standard deviation of forecast errors is somewhat misleading since forecast errors
% are one-sided. Nonetheless, the standard deviation offers a qualitative guide to the variability
% of forecast errors.

mFError = NaN(size(FError));
sFError = NaN(size(FError));
for i = 1:n
	mFError(:,i) = nanmean(FError(:,i));
	sFError(:,i) = nanstd(FError(:,i));
end

for i = 1:n
	subplot(ceil(n/2),2,i,'align');
	plot(FDates,FError(:,i));
	hold on
	plot(FDates,mFError(:,i),'g');
	plot(FDates,[mFError(:,i) - sFError(:,i),mFError(:,i) + sFError(:,i)],':r');
	recessionplot;
	dateaxis('x',12);	
 	if i == 1
 		title(['\bfForecast Accuracy for ' sprintf('%g',Horizon/4) '-Year Horizon']);
	end
	h = legend(YSeries{i},'Location','best');
	h.FontSize = 7;
	h.Box = 'off';
	hold off
end

%%
% With the exception of private investment, all forecasts tend to fall within plus or minus 2% of
% their realized values over a 1 year time horizon. However, around recessions, the errors tend to
% be larger - which implies either unmodeled or mismodeled effects that have not been captured in
% our linearized model.

%% Analysis to the End of 2008
%
% Let's look at our forecasts in greater detail. We calibrate the model at the end of 2008 to see
% how the fiscal meltdown of the prior few months might play out. The model is our VAR(2) model with
% calibration over the period from 1959 to 2008 and with forecasts 5 years into the future.
%
% The results are plotted below, where actual data are plotted with green dots, forecasts are
% identified with both a blue line for the mean forecast and red dotted lines for the standard
% deviations of the forecast.

nAR = 2;

% Set up date range

StartDate = lbusdate(1959,3);
EndDate = lbusdate(2007,12);

if StartDate < dates(1)
	error(message('econ:Demo_USEconModel:EarlyStartDate', datestr( dates( 1 ), 1 )));
end
if EndDate > dates(end)
	error(message('econ:Demo_USEconModel:LateStartDate', datestr( dates( end ), 1 )));
end

% Locate indexes in data for specified date range

iStart = find(StartDate <= dates,1);
if iStart < 1
	iStart = 1;
end
iEnd = find(EndDate <= dates,1);
if iEnd > numel(dates)
	iEnd = numel(dates);
end

% Set up data for estimation

D1 = dates(iStart:iEnd,:);			% dates for specified date range
if iStart > 1
	Y0 = Y(1:iStart-1,:);			% presample data
else
	Y0 = [];
end
Y1 = Y(iStart:iEnd,:);				% estimation data

% Set up model and estimate coefficients

Spec = vgxset('n', n, 'Constant', true, 'nAR', nAR, 'Series', YSeries, 'Info', YInfo);
Spec = vgxvarx(Spec, Y1, [], Y0);

% Do forecasts

FT = 20;
FD = Example_QuarterlyDates(dates(iEnd), FT);

[FY, FYCov] = vgxpred(Spec, FT, [], Y1);
FYSigma = zeros(size(FY));
for t = 1:FT
	FYSigma(t,:) = sqrt(diag(FYCov{t}))';
end

Hw = 20;                                    % number of historical quarters to display
Fw = 20;                                    % number of forecast quarters to display
Ow = max(0,min(Fw,(size(Y,1) - iEnd)));     % overlap between historical and forecast data

%clf;
figure

for i = 1:n
	subplot(ceil(n/2),2,i,'align');
	plot(D1(end-Hw+1:end),Y1(end-Hw+1:end,i));
	hold on
	scatter(dates(iEnd-Hw+1:iEnd+Ow),Y(iEnd-Hw+1:iEnd+Ow,i),'.');
	plot([D1(end); FD],[Y1(end,i); FY(:,i)],'b');
	plot(FD,[FY(:,i) - FYSigma(:,i), FY(:,i) + FYSigma(:,i)],':r');
	dateaxis('x',12);
	if i == 1
		title(['\bfModel Calibration to ' sprintf('%s',datestr(dates(iEnd),1))]);
	end
	h = legend(YSeries{i},'Location','best');
	h.FontSize = 7;
	h.Box = 'off';
	hold off
end

%%
% This plot suggests that, from the end of 2008 onward, a recovery is likely to begin sometime in
% 2009 - but with two distinct results. At the level of the macro economy, the model suggests that
% output will increase but with an increase in both interest rates and inflation. At the household
% level, however, the recovery might take longer which is most evident in the gradual reduction of
% unemployment.
%
% This section of code can be run with different start and end dates. Specifically, if you run the
% model to the end of 2006 (change EndDate to |lbusdate(2006,12)|), you can see hints of an upcoming
% downturn with a projected small dip in real GDP (GDP net the GDP deflator), a small drop in hours
% worked and a small rise in unemployment. Thus, at the end of 2006, our model predicted a slowdown
% or mild recession.

%%
% To set up the forecast dates for the plot, we use the following helper function which is also used
% in the next analysis.

type Example_QuarterlyDates.m

%% Analysis to the Current Available Date
%
% We now repeat our previous analysis with more recent data. With downloaded data from FRED, we can
% run our analysis on the most current available data. Otherwise, we have data to the end of March
% 2009.

nAR = 2;

% Set up date range

StartDate = lbusdate(1959,3);
EndDate = dates(end);

if StartDate < dates(1)
	error(message('econ:Demo_USEconModel:EarlyStartDate', datestr( dates( 1 ), 1 )));
end
if EndDate > dates(end)
	error(message('econ:Demo_USEconModel:LateStartDate', datestr( dates( end ), 1 )));
end

% Locate indexes in data for specified date range

iStart = find(StartDate <= dates,1);
if iStart < 1
	iStart = 1;
end
iEnd = find(EndDate <= dates,1);
if iEnd > numel(dates)
	iEnd = numel(dates);
end

% Set up data for estimation

D1 = dates(iStart:iEnd,:);			% dates for specified date range
if iStart > 1
	Y0 = Y(1:iStart-1,:);			% presample data
else
	Y0 = [];
end
Y1 = Y(iStart:iEnd,:);				% estimation data

% Set up model and estimate coefficients

Spec = vgxset('n', n, 'Constant', true, 'nAR', nAR, 'Series', YSeries, 'Info', YInfo);
Spec = vgxvarx(Spec, Y1, [], Y0);

% Do forecasts

FT = 20;
FD = Example_QuarterlyDates(dates(iEnd), FT);

[FY, FYCov] = vgxpred(Spec, FT, [], Y1);
FYSigma = zeros(size(FY));
for t = 1:FT
	FYSigma(t,:) = sqrt(diag(FYCov{t}))';
end

Hw = 20;                                    % number of historical quarters to display
Fw = 20;                                    % number of forecast quarters to display
Ow = max(0,min(Fw,(size(Y,1) - iEnd)));     % overlap between historical and forecast data

%clf;
figure

for i = 1:n
	subplot(ceil(n/2),2,i,'align');
	plot(D1(end-Hw+1:end),Y1(end-Hw+1:end,i));
	hold on
	scatter(dates(iEnd-Hw+1:iEnd+Ow),Y(iEnd-Hw+1:iEnd+Ow,i),'.');
	plot([D1(end); FD],[Y1(end,i); FY(:,i)],'b');
	plot(FD,[FY(:,i) - FYSigma(:,i), FY(:,i) + FYSigma(:,i)],':r');
	dateaxis('x',12);
	if i == 1
		title(['\bfModel Calibration to ' sprintf('%s',datestr(dates(iEnd),1))]);
	end
	h = legend(YSeries{i},'Location','best');
	h.FontSize = 12;
	h.Box = 'off';
	hold off
end

%%
% How well does the model perform given this new information? Some things to consider are changes
% between the prior analysis to the end of 2008 and the current analysis. The backtest suggests that
% the model is reasonably accurate for a period of about 1 year, which would imply that the realized
% values ought to fall within the 1 standard deviation error bands over the next 4 quarters.

%% Impulse Response Analysis
%
% For policymakers, a primary question is - what is likely to happen if a particular change occurs,
% especially if it is a change due to a policy decision? An impulse response analysis provides a
% _ceteris paribus_ sensitivity analysis of the dynamics of a system. The following plot shows the
% projected dynamic responses of each time series along each column in reaction to a 1 standard
% deviation impulse along each row. The units for each plot are percentage deviations from the
% initial state for each time series.

Impulses = YAbbrev;
Responses = YAbbrev;

W0 = zeros(FT, n);

%clf;
figure

ii = 0;
for i = 1:n
	WX = W0;
	WX(1,i) = sqrt(Spec.Q(i,i));
	YX = 100*(vgxproc(Spec, WX, [], Y1) - vgxproc(Spec, W0, [], Y1));
	for j = 1:n
		ii = ii + 1;
		subplot(n,n,ii,'align');
		plot(YX(:,j));
		if i == 1
			title(['\bf ' Responses{j}]);
		end
		if j == 1
			ylabel(['\bf ' Impulses{i}]);
		end
		ax = gca;
		if i == n
			ax.XTickMode = 'auto';
		else
			ax.XTick = [];
		end
	end
end

%% Real GDP Forecast
%
% The final analysis is a forecast of real GDP based on the calibrated model to the current
% available date. The projected value is compared with a long-term trend value based on the past 30
% years of real GDP data.

iY1 = iY(iStart:iEnd,:);

% Simulate forecasts of cumulative values of model time series

NumPaths = 1000;
iFY = vgxsim(Spec, FT, [], Y1, [], NumPaths);
iFY = repmat(iY1(end,:),[FT,1,NumPaths]) + 0.25*cumsum(iFY);
iFY = iFY(:,1,:) - iFY(:,2,:);
FGDP = mean(iFY,3);
FGDPSigma = std(iFY,0,3);
FGDP0 = GDP(iEnd) - DEF(iEnd);

w = 120;
H = [ ones(w,1) (1:w)' ];
trendParam = H \ (GDP(iEnd - w + 1:iEnd) - DEF(iEnd - w + 1:iEnd));
trendFGDP = [ ones(FT,1) w + (1:FT)' ] * trendParam;

%clf;
figure

plot(FD, [FGDP, trendFGDP]);
hold on
plot(FD, [FGDP - FGDPSigma, FGDP + FGDPSigma],':r');
title(['\bfReal GDP Forecast Based on Data to End of ' sprintf('%s',datestr(dates(iEnd),1))]);
dateaxis('x',12);
legend('Forecast','Long-Term Trend','Location','Best');
grid on;
ylabel('Log Real GDP');

%%
% If the forecast curve starts below and then approaches the trend line, this implies an expansion -
% and recovery - since GDP growth would have to exceed trend growth to return to the trend line.
% This result is the case for forecasts from late 2008 or early 2009, which would suggest a strong
% recovery during 2010.

%% Conclusion
%
% This example shows a few things you can do with the multiple time series analysis tools in the
% Econometrics Toolbox. We have shown that a VAR model based loosely on the Smets-Wouters model
% provides reasonably accurate forecasts for most of the economic series in our model. Thus, the
% scripts in this example are a good point of departure to begin testing your own ideas in
% macroeconomic modeling and analysis.

%% References
%
% # M. Del Negro, F. Schorfheide, F. Smets, and R. Wouters (2007), "On the Fit of New Keynesian
% Models," _Journal of Business & Economic Statistics_, Vol. 25, No. 2, pp. 123-162.
% # FRED, St. Louis Federal Reserve, Federal Reserve Economic Database,
% <http://research.stlouisfed.org/fred2/>.
% # M. Kimball (1995), "The Quantitative Analytics of the Basic Neomonetarist Model", _Journal of
% Money, Credit, and Banking_, _Part 2: Liquidity, Monetary Policy, and Financial Intermediation_,
% Vol. 27, No. 4, pp. 1241-1277.
% # H. Lutkepohl (2006). _New Introduction to Multiple Time Series Analysis_, Springer.
% # H. Lutkepohl and M. Kratzig (2004). _Applied Time Series Econometrics_, Cambridge University
% Press.
% # NBER, National Bureau of Economic Research, _Business Cycle Expansions and Contractions_,
% <http://www.nber.org/cycles/cyclesmain.html>.
% # F. Smets and R. Wouters (2002), _An Estimated Stochastic Dynamic General Equilibrium Model of
% the Euro Area_, European Central Bank, Working Paper Series, No. 171. Also in _Journal of the
% European Economic Association_, Vol. 1, No. 5, 2003, pp. 1123-1175.
% # F. Smets and R. Wouters (2004), _Comparing Shocks and Frictions in US and Euro Area Business
% Cycles: A Bayesian DSGE Approach_, European Central Bank, Working Paper Series, No. 391. Also in
% _Journal of Applied Econometrics_, Vol. 20, No. 1, 2005, pp. 161-183.
% # F. Smets and R. Wouters (2007), _Shocks and Frictions in US Business Cycles: A Bayesian DSGE
% Approach_, European Central Bank, Working Paper Series, No. 722. Also in _American Economic
% Review_, Vol. 97, No. 3, 2007, pp. 586-606.

displayEndOfDemoMessage(mfilename)
toc

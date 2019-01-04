%clears all variables and resets code for fresh use
clear;
%open connection and set data retrievel format
c = blp;
c.DataReturnFormat = 'timetable';
c.DatetimeType = 'datetime';
format bank
startDate = 'Jan 1 00';
endDate = today;
start_year = year(startDate);
end_year = year(endDate);

%specify asset classes
etfs_list = {'IYW US Equity','XLF US Equity','XLV US Equity',...
   'HEDJ US Equity','DXJ US Equity','TIP US Equity','BWX US Equity',...
   'SHY US Equity','IEF US Equity','IEI US Equity','TLT US Equity',...
   'GOVT US Equity','BIL US Equity','MBB US Equity','HYG US Equity',...
   'BKLN US Equity','LQD US Equity','VCSH US Equity','VCIT US Equity',...
   'JNK US Equity','FLOT US Equity','SJNK US Equity','EMB US Equity',...
   'MCHI US Equity','EEM US Eqwuity', 'EWZ US Equity','EWJ US Equity',...
   'INDA US Equity', 'RSK US Equity', 'EWW US Equity', 'HEWG US Equity',...
   'BOTZ US Equity', 'IXN US Equity',...
   'SPY US Equity', 'NEAR US Equity'};


% separates ticker name for each etf from full etf name
    Asset = [];
for i = 1:length(etfs_list)
    name = strtok(etfs_list{i});
    Asset{i} = name;
end

[etfs_cell_array] = history(c, etfs_list ,'LAST_PRICE', startDate, endDate,...
    {'daily','actual','all_calendar_days','previous_value'});
    %Maturity, Coupon, Ticker
close(c)

% pulls last price from etf timetables and stores it in Data
for i = 1:length(etfs_list)
    data = etfs_cell_array{1,i}.Variables;
    Data(:,i) = data;
end

% extracts the first monday of every month in given time range
for j = start_year:end_year
  for i = 1:12
    Date(i + 12 * (j - start_year),1) = nweekdate(1, 2, j, i); 
  end
end

%creates Asset returns
AssetReturns = tick2ret(Data);

% creates matrix for allocations
maxAllocation =    blkdiag(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
equityAllocation = blkdiag(1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,1,0,1,0);
bondAllocation =   blkdiag(0,0,0,0,0,1,1,1,1,1,1,1,0,1,0,0,1,1,1,0,1,0,1,0,0);
cashAllocation =   blkdiag(0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1);

% save data in .mat file
save('ETF_Variables.mat','Asset','Data','Date','AssetReturns','maxAllocation',...
    'equityAllocation', 'bondAllocation', 'cashAllocation');


                                          % SETUP %
%clears all variables
clear;
%open connection and set data retrievel format
c = blp;
c.DataReturnFormat = 'timetable';
c.DatetimeType = 'datetime';
format bank

%initial variables
startDate = 'Jan 1 00';
endDate = today;
start_year = year(startDate);
end_year = year(endDate);
current_year = year(today);
capital = 50000000;

% establish country constraints
brazil_bonds_percentage = 0.20;
codelco_bonds_percentage = 0.2;
chile_bonds_percentage = 0.2;
colombia_bonds_percentage = 0.2;
hungary_bonds_percentage = 0.2;
indonesia_bonds_percentage = 0.2;
mexico_bonds_percentage = 0.2;
panama_bonds_percentage = 0.2;
peru_bonds_percentage = 0.2;
phillipines_bonds_percentage = 0.2;
russian_bonds_percentage = 0.2;
south_african_bonds_percentage = 0.2;
turkey_bonds_percentage = 0.2;
venezuela_bonds_percentage = 0.2;
usa_bonds_percentage = 0.2;
ireland_bonds_percentage = 0.2;
france_bonds_percentage = 0.2;
cayman_islands_percentage = 0.2;

% establish credit rating constraints
high_grade_bonds_percentage = 1;
upper_medium_grade_bonds_percentage = 0.6;
lower_medium_grade_bonds_percentage = 0.4;
junk_grade_bonds_percentage = 0.4;

% establish years to maturity constraints
setA_years_percentage = 0.7;  %setA = 0,1 years
setB_years_percentage = 0.5;  %setB = 2,3 years
setC_years_percentage = 0.5;  %setC = 4,5 years
setD_years_percentage = 0.5;  %setD = 6,7 years
setE_years_percentage = 0.5;  %setE = 8,9,10 years
setF_years_percentage = 0.5;  %setF = other years

%establish currrency constraints
USD_bonds = 1.0;
EUR_bonds = 1.0;

%list bonds
bonds_list = { '/isin/US05968LAG77','/isin/US26138EAP43','/isin/US279158AC30','/isin/US345397YC16',...
     '/isin/US37045VAM28','/isin/US451102BF38','/isin/US472319AL69','/isin/US606822AS32',...
     '/isin/US60687YAN94','/isin/US61744YAG35','/isin/US71654QBG64','/isin/US74913GAX34',...
     '/isin/US81180WAH43','/isin/US912796QS12','/isin/USG0457FAC17','/isin/USG3925DAA84',...
     '/isin/USG42045AB32','/isin/USG53770AB22','/isin/USN54468AF52','/isin/USP09646AC75',...
     '/isin/USP1265VAA00','/isin/USP1507SAC19','/isin/USP16259AH99','/isin/USP16260AA28',...
     '/isin/USP1905CAD22','/isin/USP2205JAH34','/isin/USP58073AA84','/isin/USP6811TAA36',...
     '/isin/XS0833886095','/isin/XS1567332884','/isin/XS1589358644','/isin/XS1641476574'};

                                        % GET DATA %
% gets last price, maturity, coupons, tickers, name, currency, and credit rating data
[bonds_cell_array] = history(c, bonds_list ,'LAST_PRICE', startDate, endDate, {'monthly','actual',...
                  'all_calendar_days','previous_value'});
[bonds_maturities] = getdata(c, bonds_list ,'Maturity');
[bonds_coupons] = getdata(c, bonds_list ,'Coupon');
[bonds_tickers] = getdata(c, bonds_list ,'Ticker');
[origin_country_name] = getdata(c, bonds_list ,'CNTRY_ISSUE_ISO');

%we used 'country' before to pull datata. This does not work as the ticker
%pulled is not consistent.
[currency_symbol] = getdata(c, bonds_list ,'currency');
[credit_rating] = getdata(c, bonds_list ,'BB_COMPOSITE');
testData = getdata(c, '/isin/US715638AU64 (d)', 'Coupon');
testDataTwo = getdata(c, '/isin/US715638AU64', 'Coupon');
% seperates bond maturity year
    for i = 1:length(bonds_list)
        string = datestr(bonds_maturities{i,1});
        cell = cellstr(string);
        bonds_maturities_year(i,1) = extractBetween(cell{1,1}, 8,11);
    end
                                      % ORGANIZE DATA %
% create label for each bond(combine ticker, coupon, and date)
for i = 1:length(bonds_list)
    tic = bonds_tickers{i, 1};
    coup = num2str(bonds_coupons{i, 1});
    dat = bonds_maturities_year{i, 1};
    dash = '-';
    percent = '%';
    Asset(1, i) = strcat(tic,dash,coup,percent,dash,dat);
end

%pulls last price from bonds timetables and stores it in Data
for i = 1:length(bonds_list)
    data = bonds_cell_array{1,i}.Variables;
    Data(:,i) = data;
end

%extracts the first monday of every month in given time range
for j = start_year:end_year
  for i = 1:12
    Date(i + 11 * (j - start_year),1) = nweekdate(1, 2, j, i); 
  end
end

%groups country percentages
grouped_bonds_percentage = [brazil_bonds_percentage, codelco_bonds_percentage,...
    chile_bonds_percentage, colombia_bonds_percentage, hungary_bonds_percentage,...
    indonesia_bonds_percentage, mexico_bonds_percentage, panama_bonds_percentage,...
    peru_bonds_percentage, phillipines_bonds_percentage, russian_bonds_percentage,...
    south_african_bonds_percentage, turkey_bonds_percentage,...
    venezuela_bonds_percentage, usa_bonds_percentage, ireland_bonds_percentage,...
    france_bonds_percentage, cayman_islands_percentage];

%groups credit rating percentages
grouped_credit_ratings_percentage = [high_grade_bonds_percentage, upper_medium_grade_bonds_percentage,...
lower_medium_grade_bonds_percentage, junk_grade_bonds_percentage];

%grouped years to maturity percentages
grouped_years_to_maturity_percentage = [setA_years_percentage, setB_years_percentage, setC_years_percentage, ...
    setD_years_percentage, setE_years_percentage, setF_years_percentage];

% grouped currency percentage
grouped_currency_percentage = [USD_bonds, EUR_bonds];

% applies coupon
unrefinedAssetReturns = tick2ret(Data);
coupons_table = table2array(bonds_coupons);
for i = 1:length(bonds_list)
  return_temp = coupons_table(i,1) / 1200;   % Shouldn't this be 12 for a monthly coupon return rather than 1200
  
    for j = 1:size(unrefinedAssetReturns,1)
      return_temp_2 = unrefinedAssetReturns(j,i);
      if (return_temp_2 ~= NaN)
        return_sum = return_temp + return_temp_2;
        AssetReturns(j,i) = return_sum;
      end
    end
end 
                               % GROUP ALLOCATIONS %
%creates on/off matrix for each constraint field
country_matrix = zeros(length(grouped_bonds_percentage), length(bonds_list));
credit_rating_matrix = zeros(length(grouped_credit_ratings_percentage), length(bonds_list));
years_to_maturity_matrix = zeros(length(grouped_years_to_maturity_percentage), length(bonds_list));
currency_matrix = zeros(length(grouped_currency_percentage), length(bonds_list));
J = 1;

% Sorts each bond into on/off matrix based on bond data
for i = 1:length(bonds_list)

       J = J + 1; 
    %sort by country    
    if strcmp(origin_country_name{i, 1}, 'BR') == 1; %BRAZIL
        country_matrix(1,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'CL') == 1; %REPUBLIC OF CHILE      
       country_matrix(2,i) = 1;
       
       
    elseif strcmp(origin_country_name{i, 1}, 'CO') == 1; %COLOMBIA
       country_matrix(3,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'HU') == 1; %HUNGARY
       country_matrix(4,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'ID') == 1; %REPUBLIC OF INDONESIA
       country_matrix(5,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'MX') == 1; %UNITED MEXICAN STATES
       country_matrix(6,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'PA') == 1; %REPUBLIC OF PANAMA
       country_matrix(7,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'PE') == 1; %PERU
       country_matrix(8,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'PH') == 1;%REPUBLIC OF PHILIPPINES
       country_matrix(9,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'RU') == 1; %RUSSIAN FEDERATION
       country_matrix(10,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'ZA') == 1; %REPUBLIC OF SOUTH AFRICA
       country_matrix(11,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'TR') == 1; %REPUBLIC OF TURKEY
       country_matrix(12,i) = 1;
       
       %bloomberg says country symbol for turkey is TR
       %but when matlab pulls it iit becomes TU????
       
    elseif strcmp(origin_country_name{i, 1}, 'VE') == 1; %REPUBLIC OF VENEZUELA
       country_matrix(13,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'US') == 1; %UNITED STATES OF AMERICA
       country_matrix(14,i) = 1;
    
    elseif strcmp(origin_country_name{i, 1}, 'IE') == 1; %UNITED STATES OF AMERICA
       country_matrix(15,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'FR') == 1; %FRANCE
       country_matrix(16,i) = 1;
    
    elseif strcmp(origin_country_name{i, 1}, 'KY') == 1; %CAYMAN ISLANDS
       country_matrix(16,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'PL') == 1; %POLAND
       country_matrix(17,i) = 1;   
       
    elseif strcmp(origin_country_name{i, 1}, 'MULT') == 1; %from multiple?
       country_matrix(18,i) = 1; 
       
    elseif strcmp(origin_country_name{i, 1}, 'NL') == 1; %NETHERLANDS
       country_matrix(19,i) = 1;   
       
    elseif strcmp(origin_country_name{i, 1}, 'SNAT') == 1; %SUPRANATIONALS
       country_matrix(20,i) = 1;   
       
    elseif strcmp(origin_country_name{i, 1}, 'NL') == 1; %NETHERLANDS
       country_matrix(21,i) = 1;      
       
    elseif strcmp(origin_country_name{i, 1}, 'GB') == 1; %GREAT BRITAIN
       country_matrix(22,i) = 1;      
       
    elseif strcmp(origin_country_name{i, 1}, 'AR') == 1; %ARGENTINA
       country_matrix(23,i) = 1;   
    
    elseif strcmp(origin_country_name{i, 1}, 'CA') == 1; %CANADA
       country_matrix(24,i) = 1;      
       
    elseif strcmp(origin_country_name{i, 1}, 'DE') == 1; %GERMANY
       country_matrix(25,i) = 1;  
       
    elseif strcmp(origin_country_name{i, 1}, 'BM') == 1; %BERMUDA ISLANDS
       country_matrix(26,i) = 1;  
       
    elseif strcmp(origin_country_name{i, 1}, 'AU') == 1; %AUSTRALIA
       country_matrix(27,i) = 1;   
       
    elseif strcmp(origin_country_name{i, 1}, 'JP') == 1; %JAPAN. Bloomberg refers dir. as JPN
       country_matrix(28,i) = 1;   
       
    elseif strcmp(origin_country_name{i, 1}, 'CH') == 1; %SWITZERLAND
       country_matrix(29,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'LU') == 1; %LUXEMBOURG
       country_matrix(30,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'HK') == 1; %HONG KONG
       country_matrix(31,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'VG') == 1; %BRITISH VIRGIN ISLANDS
       country_matrix(32,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'DO') == 1; %DOMINICAN REPUBLIC
       country_matrix(33,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'SE') == 1; %SWEDEN
       country_matrix(34,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'CN') == 1; %CHINA
       country_matrix(35,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'KR') == 1; %SOUTH KOREA
       country_matrix(36,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'IN') == 1; %INDIA
       country_matrix(37,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'CR') == 1; %COSTA RICA
       country_matrix(38,i) = 1;
       
    else
       error('Unable to sort bond by country.');
    end

%     
    %sort by years to maturity
    bond_year = str2double(bonds_maturities_year{i,1});
    years_to_maturity = bond_year - current_year;
    years_matrix(1,i) = years_to_maturity;
    if ((years_to_maturity == 0) | (years_to_maturity == 1));
        years_to_maturity_matrix(1,i) = 1;
        
    elseif ((years_to_maturity == 2) | (years_to_maturity == 3));
        years_to_maturity_matrix(2,i) = 1;   
        
    elseif ((years_to_maturity == 4) | (years_to_maturity == 5));
        years_to_maturity_matrix(3,i) = 1;
        
    elseif ((years_to_maturity == 6) | (years_to_maturity == 7));
        years_to_maturity_matrix(4,i) = 1;
        
    elseif ((years_to_maturity == 8) | (years_to_maturity == 9) | (years_to_maturity == 10));
        years_to_maturity_matrix(5,i) = 1;
    
    elseif (years_to_maturity > 10);
        years_to_maturity_matrix(6,i) = 1;
    
    else
        error('Unable to sort bond by years to maturity.');
    end 
    
   
                                    % DISPLAY %
%picks first label of each country
isins_first_position(1,1) = 1;
temp = 1;
bonds_per_country = sum(country_matrix, 2);
for i = 1:(length(grouped_bonds_percentage)-1)
    temp = temp + bonds_per_country(i,1);
    isins_first_position(1,i+1) = temp;
end

% makes array of first bond per country
% position of the first time any given country has a bond appear
for i = 1:length(bonds_list)
    if (any(isins_first_position == i)) % this part is supposed to say "is i equal to any value in first isin position?
        %if the above line is fixed the rest will work.
        overrideAssets(1,i) = Asset(1,i);
    else
       overrideAssets(1,i) = {''};
    end
end
restoreAssets = Asset;

%creates Asset returns
AssetReturns = tick2ret(Data);



                                % FINILIZATION %
%close BB connection
close(c)
%save data in .mat file
    %asset will be bond labels, data is bond prices
save('Bonds_data_Cinepolis.mat','Asset','Data','Date', ...
'grouped_bonds_percentage', 'AssetReturns', 'overrideAssets',...
'restoreAssets', 'country_matrix', 'credit_rating_matrix', 'grouped_credit_ratings_percentage',...
'grouped_years_to_maturity_percentage', 'years_to_maturity_matrix', 'grouped_currency_percentage',...
'currency_matrix','AssetReturns');
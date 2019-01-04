                                          % SETUP %
%clears all variables
clear;
%open connection and set data retrievel format
c = blp;
c.DataReturnFormat = 'timetable';
c.DatetimeType = 'datetime';
format bank

%initial variables
startDate = 'Jan 1 10';
endDate = today;
start_year = year(startDate);
end_year = year(endDate);
current_year = year(today);

% establish country constraints
brazil_bonds_percentage = 0.0;
codelco_bonds_percentage = 0.2;
chile_bonds_percentage = 0.0;
colombia_bonds_percentage = 0.2;
hungary_bonds_percentage = 0.0;
indonesia_bonds_percentage = 0.0;
mexico_bonds_percentage = 0.1;
panama_bonds_percentage = 0.1;
peru_bonds_percentage = 0.1;
phillipines_bonds_percentage = 0.1;
russian_bonds_percentage = 0.0;
south_african_bonds_percentage = 0.1;
turkey_bonds_percentage = 0.1;
venezuela_bonds_percentage = 0.0;

%establish credit rating contraints
high_grade_bonds_percentage = 0.3;
upper_medium_grade_bonds_percentage = 0.5;
lower_medium_grade_bonds_percentage = 0.4;
junk_grade_bonds_percentage = 0.2;

                                        % LIST BONDS %
    %specify asset classes
    %the first four have too many NaN values and is skewing data
bonds_list = {%'/isin/USP04808AG92','/isin/USP04808AA23','/isin/USP04808AC88',...
   % '/isin/US040114GY03'
    '/isin/US105756BU30','/isin/US105756BK57','/isin/US105756BR01',...
    '/isin/USP3143NAJ39','/isin/US168863AV04','/isin/US195325BL83','/isin/USP3772NHK11',...
    '/isin/US195325BB02','/isin/US195325BK01','/isin/US195325BM66','/isin/US445545AE60',...
    '/isin/US445545AH91','/isin/US445545AF36','/isin/USY20721AP44','/isin/USY20721AJ83',...
    '/isin/USY20721AL30','/isin/USY20721BB49','/isin/USY20721BE87','/isin/US91086QBD97',...
    '/isin/US91086QAS75','/isin/US91086QAV05','/isin/US91086QBB32','/isin/US91086QBE70',...
    '/isin/US91086QAZ19','/isin/US698299AW45','/isin/US698299BB98','/isin/US715638AW21',...
    '/isin/US715638AU64','/isin/US715638BM30','/isin/US718286BE62','/isin/US718286BF38',...
    '/isin/US718286BN61','/isin/US718286BD89','/isin/XS0767472458','/isin/XS0088543193',...
    '/isin/XS0114288789','/isin/XS0767473852','/isin/US836205AM61','/isin/US836205AL88',...
    '/isin/US836205AP92','/isin/US900123BF62','/isin/US900123CA66','/isin/US900123AL40',...
    '/isin/US900123BG46','/isin/US900123BJ84','/isin/US900123CB40','/isin/US900123CG37',...
    '/isin/USP17625AC16','/isin/USP17625AA59','/isin/USP97475AP55','/isin/US922646AS37',...
    '/isin/USP17625AB33'};

                                        % GET DATA %
[bonds_cell_array] = history(c, bonds_list ,'LAST_PRICE', startDate, endDate, {'monthly','actual',...
                  'all_calendar_days','nil_value'});
[bonds_maturities] = getdata(c, bonds_list ,'Maturity');
[bonds_coupons] = getdata(c, bonds_list ,'Coupon');
[bonds_tickers] = getdata(c, bonds_list ,'Ticker');
[origin_country_name] = getdata(c, bonds_list ,'Name');
[currency_symbol] = getdata(c, bonds_list ,'currency');
[credit_rating] = getdata(c, bonds_list ,'BB_COMPOSITE');

%seperates bond maturity year
    for i = 1:length(bonds_list)
        string = datestr(bonds_maturities{i,1});
        cell = cellstr(string);
        bonds_maturities_year(i,1) = extractBetween(cell{1,1}, 8,11);
    end
                                      % ORGANIZE DATA %
%create label for each bond(combine ticker, coupon, and date)
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

%sorts bonds by time until maturity year
lbl = num2cell([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q] = deal(lbl{:});
for i = 1:length(bonds_list);
    bond_year = str2double(bonds_maturities_year{i,1});
    years_to_maturity = bond_year - current_year;
    if years_to_maturity == 0;
        under_year_bonds(A,1) = bonds_list(1,i);
        A = A + 1;
    elseif years_to_maturity == 1;
        year_bonds(B,1) = bonds_list(1,i);
        B = B + 1;
    elseif years_to_maturity == 2;
        two_year_bonds(C,1) = bonds_list(1,i);
        C = C + 1;
    elseif years_to_maturity == 3;
        three_year_bonds(D,1) = bonds_list(1,i);
        D = D + 1;
    elseif years_to_maturity == 4;
        four_year_bonds(E,1) = bonds_list(1,i);
        E = E + 1;
    elseif years_to_maturity == 5;
       five_year_bonds(F,1) = bonds_list(1,i);
        F = F + 1;
    elseif years_to_maturity == 6;
       six_year_bonds(G,1) = bonds_list(1,i);
        G = G + 1;
    elseif years_to_maturity == 7;
       seven_year_bonds(H,1) = bonds_list(1,i);
        H = H + 1;
    elseif years_to_maturity == 8;
       eight_year_bonds(I,1) = bonds_list(1,i);
        I = I + 1;
    elseif years_to_maturity == 9;
       nine_year_bonds(J,1) = bonds_list(1,i);
        J = J + 1;
    elseif years_to_maturity == 10;
       ten_year_bonds(K,1) = bonds_list(1,i);
        K = K + 1;
    elseif years_to_maturity == 11;
        eleven_year_bonds(L,1) = bonds_list(1,i);
        L = L + 1;
    elseif years_to_maturity == 12;
        twelve_year_bonds(M,1) = bonds_list(1,i);
        M = M + 1;
    elseif years_to_maturity == 13;
        thirteen_year_bonds(N,1) = bonds_list(1,i);
        N = N + 1;
    elseif years_to_maturity == 14;
        fourteen_year_bonds(O,1) = bonds_list(1,i);
        O = O + 1;
    elseif years_to_maturity == 15;
        fifteen_year_bonds(P,1) = bonds_list(1,i);
        P = P + 1;
    elseif years_to_maturity >= 16;
        over_fifteen_year_bonds(Q,1) = bonds_list(1,i);
        Q = Q + 1;
    end
end

%sort bonds by credit rating
A = 1;
B = 1;
C = 1;
D = 1;
for i = 1:length(bonds_list);
    rating = credit_rating{i,1};
    if (strcmpi(rating,'AAA') | strcmpi(rating,'AA+') | ...
            strcmpi(rating,'AA') | strcmpi(rating,'AA-')) == 1;
        high_grade_bonds(1,A) = bonds_list(1,i);
        A = A + 1;
    elseif (strcmpi(rating,'A+') | strcmpi(rating,'A') | ...
            strcmpi(rating,'A-')) == 1;
        upper_medium_grade_bonds(1,B) = bonds_list(1,i);
        B = B + 1;
    elseif (strcmpi(rating,'BBB+') | strcmpi(rating,'BBB') | ...
            strcmpi(rating,'BBB-')) == 1;
        lower_medium_grade_bonds(1,C) = bonds_list(1,i);
        C = C + 1;
    else
        junk_grade_bonds(1,D) = bonds_list(1,i);
        D = D + 1;
    end
end

%sort bonds by county into seperate lists
lbl = num2cell([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O] = deal(lbl{:});
for i = 1:length(bonds_list)
    if strcmp(origin_country_name{i, 1}, 'REPUBLIC OF ARGENTINA') == 1;
        argentina_bonds(1,A) = bonds_list(1,i);
        A = A + 1;
    elseif strcmp(origin_country_name{i, 1}, 'FED REPUBLIC OF BRAZIL') == 1;
        brazil_bonds(1,B) = bonds_list(1,i);
        B = B + 1;
    elseif strcmp(origin_country_name{i, 1}, 'CODELCO INC') == 1;
       codelco_bonds(1,C) = bonds_list(1,i);
       C = C + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF CHILE') == 1;
       chile_bonds(1,D) = bonds_list(1,i);
       D = D + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF COLOMBIA') == 1;
       colombia_bonds(1,E) = bonds_list(1,i);
       E = E + 1;
    elseif strcmp(origin_country_name{i, 1}, 'HUNGARY') == 1;
       hungary_bonds(1,F) = bonds_list(1,i);
       F = F + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF INDONESIA') == 1;
       indonesia_bonds(1,G) = bonds_list(1,i);
       G = G + 1;
    elseif strcmp(origin_country_name{i, 1}, 'UNITED MEXICAN STATES') == 1;
       mexico_bonds(1,H) = bonds_list(1,i);
       H = H + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF PANAMA') == 1;
       panama_bonds(1,I) = bonds_list(1,i);
       I = I + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF PERU') == 1;
       peru_bonds(1,J) = bonds_list(1,i);
       J = J + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF PHILIPPINES') == 1;
        phillipines_bonds(1,K) = bonds_list(1,i);
       K = K + 1;
    elseif strcmp(origin_country_name{i, 1}, 'RUSSIAN FEDERATION') == 1;
       russian_bonds(1,L) = bonds_list(1,i);
       L = L + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF SOUTH AFRICA') == 1;
       south_african_bonds(1,M) = bonds_list(1,i);
       M = M + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF TURKEY') == 1;
       turkey_bonds(1,N) = bonds_list(1,i);
       N = N + 1;
    elseif strcmp(origin_country_name{i, 1}, 'REPUBLIC OF VENEZUELA') == 1;
       venezuela_bonds(1,O) = bonds_list(1,i);
       O = O + 1;
    end
end
clearvars lbl A B C D E F G H I J K L M N O P Q country_check;

%extracts the first monday of every month in given time range
for j = start_year:end_year
  for i = 1:12
    Date(i + 12 * (j - start_year),1) = nweekdate(1, 2, j, i); 
  end
end

%makes a cell array with all bonds grouped by country name for percentage
%allocation
grouped_bonds_percentage = [brazil_bonds_percentage, codelco_bonds_percentage,...
    chile_bonds_percentage, colombia_bonds_percentage, hungary_bonds_percentage,...
    indonesia_bonds_percentage, mexico_bonds_percentage, panama_bonds_percentage,...
    peru_bonds_percentage, phillipines_bonds_percentage, russian_bonds_percentage,...
    south_african_bonds_percentage, turkey_bonds_percentage,...
    venezuela_bonds_percentage];
%make a cell array with all bond isins grouped by country name
grouped_bonds_isins = {brazil_bonds, codelco_bonds,...
    chile_bonds, colombia_bonds, hungary_bonds, indonesia_bonds,mexico_bonds...
    panama_bonds,peru_bonds,...
    phillipines_bonds, russian_bonds,...
    south_african_bonds, turkey_bonds,...
    venezuela_bonds};
%groups credit rating percentages
grouped_credit_ratings_percentage = [high_grade_bonds_percentage, upper_medium_grade_bonds_percentage,...
lower_medium_grade_bonds_percentage, junk_grade_bonds_percentage];

%creates on/off array
j = 1;
for i = 1:length(grouped_bonds_percentage)
    if (grouped_bonds_percentage(1,i) == 0)
       temp = blkdiag(false(1,length(grouped_bonds_isins{1,i})));
       sys{j,i} = temp;
       ++j;
    else
       temp = blkdiag(true(1,length(grouped_bonds_isins{1,i})));
       sys{j,i} = temp;
       ++j;
    end
end

bonds_diagonal = blkdiag(sys{1,1}, sys{1,2}, sys{1,3}, sys{1,4}, sys{1,5}, sys{1,6},...
sys{1,7}, sys{1,8}, sys{1,9}, sys{1,10}, sys{1,11}, sys{1,12}, sys{1,13}, sys{1,14});

%creates bonds diagonal
 for i= 1:length(grouped_bonds_percentage)
    A = bonds_diagonal(i,:);
    B = grouped_bonds_percentage(1,i);
 end
%applies coupon
unrefinedAssetReturns = tick2ret(Data);
coupons_table = table2array(bonds_coupons);
for i = 1:length(bonds_list)
  return_temp = coupons_table(i,1) / 1200;
    for j = 1:size(unrefinedAssetReturns,1)
      return_temp_2 = unrefinedAssetReturns(j,i);
      if (return_temp_2 ~= NaN)
        return_sum = return_temp + return_temp_2;
        AssetReturns(j,i) = return_sum;
      end
    end
end 

for  

                                    % DISPLAY %
%picks first label of each country
isins_first_position(1,1) = 1;
temp = 1;
for i = 1:(length(grouped_bonds_percentage)-1)
    temp = temp + length(grouped_bonds_isins{1,i});
    isins_first_position(1,i+1) = temp;
end

%makes array of first bond per country
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

                                % FINILIZATION %
close(c)
%save data in .mat file
%asset will be bond labels, data is bond prices
save('conservativeVariables.mat','Asset','Data','Date', 'bonds_diagonal',...
'grouped_bonds_percentage', 'AssetReturns', 'overrideAssets',...
'restoreAssets');
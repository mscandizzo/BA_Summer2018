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
capital = 50000000;

% establish country constraints
brazil_bonds_percentage = 0.0;
codelco_bonds_percentage = 0.0;
chile_bonds_percentage = 0.2;
colombia_bonds_percentage = 0.2;
hungary_bonds_percentage = 0.2;
indonesia_bonds_percentage = 0.2;
mexico_bonds_percentage = 0.2;
panama_bonds_percentage = 0.2;
peru_bonds_percentage = 0.2;
phillipines_bonds_percentage = 0.2;
russian_bonds_percentage = 0.0;
south_african_bonds_percentage = 0.0;
turkey_bonds_percentage = 0.0;
venezuela_bonds_percentage = 0.0;
usa_bonds_percentage = 0.0;
ireland_bonds_percentage = 0.0;
france_bonds_percentage = 0.0;
cayman_islands_percentage = 0.0;

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
full_bonds_list = {
    %
    %'/isin/US05574LTX63','/isin/US40428HPJ58','/isin/US81180WAP68'...
    %'/isin/US105756BU30','/isin/US105756BK57','/isin/US105756BR01',...
    %%'/isin/USP3143NAJ39','/isin/US168863AV04','/isin/US195325BL83','/isin/USP3772NHK11',...
    %'/isin/US195325BB02','/isin/US195325BK01','/isin/US195325BM66','/isin/US445545AE60',...
    %'/isin/US445545AH91','/isin/US445545AF36','/isin/USY20721AP44','/isin/USY20721AJ83',...
    %'/isin/USY20721AL30','/isin/USY20721BB49','/isin/USY20721BE87','/isin/US91086QBD97',...
    %'/isin/US91086QAS75','/isin/US91086QAV05','/isin/US91086QBB32','/isin/US91086QBE70',...
    %'/isin/US91086QAZ19','/isin/US698299AW45','/isin/US698299BB98','/isin/US715638AW21',...
    %'/isin/US715638AU64','/isin/US715638BM30','/isin/US718286BE62','/isin/US718286BF38',...
    %'/isin/US718286BN61','/isin/US718286BD89','/isin/XS0767472458','/isin/XS0088543193',...
    %'/isin/XS0114288789','/isin/XS0767473852','/isin/US836205AM61','/isin/US836205AL88',...
    %'/isin/US836205AP92','/isin/US900123BF62','/isin/US900123CA66','/isin/US900123AL40',...
    %'/isin/US900123BG46','/isin/US900123BJ84','/isin/US900123CB40','/isin/US900123CG37',...
    %'/isin/USP17625AC16','/isin/USP17625AA59','/isin/USP97475AP55','/isin/US922646AS37',...
    %'/isin/US105756AE07','/isin/US105756AR10','/isin/US715638AU64 (d)','/isin/US715638AW21 (d)',...
    %'/isin/US715638BM30 (d)','/isin/US718286AK32','/isin/US718286AP29 (d)','/isin/US718286AY36 (d)',...
    %'/isin/US718286BB24','/isin/US718286BD89','/isin/US718286BE62 (d)','/isin/US718286BF38',...
    %'/isin/US718286BG11 (d)','/isin/US718286BK23','/isin/US718286BN61 (d)','/isin/US718286BW60 (d)',... 
    %'/isin/US718286BY27 (d)','/isin/US718286BZ91','/isin/US731011AR30 (d)','/isin/US731011AT95 (d)',...
    %'/isin/US760942AS16','/isin/US760942AY83','/isin/US760942AZ58','/isin/US760942BA98',...
    %'/isin/US77586TAA43 (d)','/isin/US77586TAC09 (d)','/isin/US77586TAD81 (d)','/isin/US77586TAE64 (d)',...
    %'/isin/US836205AL88 (d)','/isin/US836205AM61 (d)','/isin/US836205AN45 (d)','/isin/US836205AP92 (d)',...
    %'/isin/US836205AQ75 (d)','/isin/US836205AR58 (d)','/isin/US836205AS32','/isin/US857524AA08 (d)',...
    %'/isin/US857524AB80 (d)','/isin/US857524AC63 (d)','/isin/US880591EP31','/isin/US900123AL40 (d)',...
    %'/isin/US900123AT75 (d)','/isin/US900123AW05 (d)','/isin/US900123AX87 (d)','/isin/US900123AY60 (d)',...
    %'/isin/US900123BB58 (d)','/isin/US900123BD15 (d)','/isin/US900123BF62 (d)','/isin/US900123BG46 (d)',...
    %'/isin/US900123BH29 (d)','/isin/US900123BJ84 (d)','/isin/US900123BY51 (d)','/isin/US900123BZ27 (d)',...
    %'/isin/USP17625AB33', '/isin/US105756BN96', '/isin/BRSTNCNTF0N5'};

    % full list of isins corresponding to GABI
    %the (d) was listed in bloomberg. Code will still functions exactly the
    %same if it is removed. I do not know what it means or does.
    %'/isin/US105756AE07','/isin/US105756AR10','/isin/US715638AU64 (d)','/isin/US715638AW21 (d)',...
    %'/isin/US715638BM30 (d)','/isin/US718286AK32','/isin/US718286AP29 (d)','/isin/US718286AY36 (d)',...
    %'/isin/US718286BB24','/isin/US718286BD89','/isin/US718286BE62 (d)','/isin/US718286BF38',...
    %'/isin/US718286BG11 (d)','/isin/US718286BK23','/isin/US718286BN61 (d)','/isin/US718286BW60 (d)',... 
    %'/isin/US718286BY27 (d)','/isin/US718286BZ91','/isin/US731011AR30 (d)','/isin/US731011AT95 (d)',...
    %'/isin/US760942AS16','/isin/US760942AY83','/isin/US760942AZ58','/isin/US760942BA98',...
    %'/isin/US77586TAA43 (d)','/isin/US77586TAC09 (d)','/isin/US77586TAD81 (d)','/isin/US77586TAE64 (d)',...
    %'/isin/US836205AL88 (d)','/isin/US836205AM61 (d)','/isin/US836205AN45 (d)','/isin/US836205AP92 (d)',...
    %'/isin/US836205AQ75 (d)','/isin/US836205AR58 (d)','/isin/US836205AS32','/isin/US857524AA08 (d)',...
    %'/isin/US857524AB80 (d)','/isin/US857524AC63 (d)','/isin/US880591EP31','/isin/US900123AL40 (d)',...
    %'/isin/US900123AT75 (d)','/isin/US900123AW05 (d)','/isin/US900123AX87 (d)','/isin/US900123AY60 (d)',...
    %'/isin/US900123BB58 (d)','/isin/US900123BD15 (d)','/isin/US900123BF62 (d)','/isin/US900123BG46 (d)',...
    %'/isin/US900123BH29 (d)','/isin/US900123BJ84 (d)','/isin/US900123BY51 (d)','/isin/US900123BZ27 (d)',...

    %  OK SO pretty sure i messed up with the bonds list we actually need
    %  to choose it from this set on google sheets
    %that being said im starting over and just using that list...
%     '/isin/US05574LTX63','/isin/US05574LPT97','/isin/US40428HPJ58','/isin/US81180WAP68',...
%     '/isin/US594918BF05','/isin/US715638AW21','/isin/US037833AP55','/isin/US822582BA91',...
%     '/isin/US459058DL43','/isin/XS0742416380','/isin/US037833AQ39',...
%     '/isin/US6174468B80','/isin/US02665WBN02','/isin/US590188JN99','/isin/US609207AC96',... 
%     '/isin/US83368RAD44','/isin/US345397XN89','/isin/US06051GFD60',...
%     '/isin/US445545AK21','/isin/US06051GEX34','/isin/US731011AR30','/isin/US126650CB43',...
%     '/isin/US78013GKP99','/isin/US66989GAA85','/isin/US2027A1JJ70','/isin/US61747YDX04',...
%     '/isin/US023135AL05','/isin/US05565QDQ82','/isin/US38141EA257','/isin/US89236TEN19',...
%     '/isin/US00206RCK68','/isin/US298785HL33','/isin/US55608KAE55','/isin/US345397YC16',...
%     '/isin/US00206RCC43','/isin/US594918AH79','/isin/US880591EN82',...
%     '/isin/US698299AX28','/isin/US345397YF47','/isin/US17275RAX08','/isin/US65535HAG48',...
%     '/isin/US46647PAG19','/isin/US718546AS30','/isin/US168863AV04','/isin/US61746BDR42',...
%     '/isin/US86960BAG77','/isin/US717081DX82','/isin/US89236TEJ07','/isin/US37045VAM28',...
%     '/isin/US191241AG32','/isin/US037833AR12','/isin/US404280BG30','/isin/US046353AF58',...
%     '/isin/US61746BDS25','/isin/US4581X0CF37','/isin/XS1641476574','/isin/USP3R94GAF68',...
%     '/isin/US023135AM87','/isin/US38148FAB58','/isin/US747525AS26','/isin/US742718DY23',...
%     '/isin/US263534CL10','/isin/XS1567332884','/isin/US931427AA66','/isin/US195325AU91',...
%     '/isin/US606822AS32','/isin/US58013MEX83','/isin/US60687YAN94','/isin/US09062XAC74',...
%     '/isin/US46625HKA76','/isin/US29736RAH30','/isin/US68389XBK00','/isin/USP58072AE24',...
%     '/isin/US01609WAC64','/isin/US302154BM07','/isin/XS1589358644','/isin/US263534CB38',...
%     '/isin/US949746SJ14','/isin/US36962GW752','/isin/US151191AQ67','/isin/US20030NBA81',...
%     '/isin/USP14486AK37','/isin/US046353AK44','/isin/US46625HNX43','/isin/US035242AJ52',...
%     '/isin/US14913QAA76','/isin/US06051GFT13','/isin/US056752AD07','/isin/USG82003AC11',...
%     '/isin/US46625HHS22','/isin/US06738EAD76','/isin/US00206RCL42','/isin/US61761JB325',...
%     '/isin/US126650CJ78','/isin/US61744YAG35','/isin/US38141GWG53','/isin/US172967LL34',...
%     '/isin/USU09513HF91','/isin/USN39427AK07','/isin/US172967KB60','/isin/US023608AF92',...
%     '/isin/US219868BX31','/isin/US857524AB80','/isin/USP1027DEN77','/isin/US428236BF92',...
%     '/isin/US22546QAD97','/isin/US91086QBD97','/isin/US44891CAG87','/isin/US195325BN40',...
%     '/isin/US42824CAG42','/isin/USP3143KEZ95','/isin/US219868BS46','/isin/US902494AT07',...
%     '/isin/XS1514047312','/isin/US25152RVS92','/isin/US345397XK41','/isin/US55608KAM71',...
%     '/isin/USP09646AC75','/isin/US168863BW77','/isin/USP1342SAC00','/isin/US06738EAT29',...
%     '/isin/US260543CF88','/isin/USN27915AJ12','/isin/US38145GAG55','/isin/US460146CG68',...
%     '/isin/USP9379RAA51','/isin/US05968LAG77','/isin/US086516AL50','/isin/US26138EAP43',...
%     '/isin/US984121CM35','/isin/US92343VBR42','/isin/US05968LAB80','/isin/US887317AQ81',...
%     '/isin/USY20721BS73','/isin/US695156AQ25','/isin/US03938LAU89','/isin/US91911TAM53',...
%     '/isin/US871503AH15','/isin/USP36020AA68','/isin/XS0563742138','/isin/USP1393HAB44',...
%     '/isin/US06738EAQ89','/isin/US12803X2D25','/isin/USP0607JAE84','/isin/USP9047EAA66',...
%     '/isin/US55608YAA38','/isin/US71654QCF72','/isin/USP82290AA81','/isin/US94974BFJ44',...
%     '/isin/US20030NBS99','/isin/US195325BD67','/isin/XS1387925958','/isin/USG42036AA42',...
%     '/isin/USP31389AY82','/isin/XS0611586263','/isin/USP58073AA84','/isin/USP16260AA28',...
%     '/isin/US06051GFH74','/isin/USP1507SAC19','/isin/US472319AL69','/isin/US29082AAA51',...
%     '/isin/US71654QAX07','/isin/USP16259AK29','/isin/USG3925DAA84','/isin/USP16259AB20',...
%     '/isin/US71654QCA85','/isin/US05968LAH50','/isin/USP2205JAE03','/isin/USP47718AA21',...
%     '/isin/USU2526DAC30','/isin/USP16259AH99','/isin/US279158AC30','/isin/US92553PAX06',...
%     '/isin/US279158AK55','/isin/US189754AA23','/isin/XS0874014722','/isin/USG42045AB32',...
%     '/isin/US093662AE40','/isin/US00206RER93','/isin/USP2205JAH34','/isin/US71654QBG64',...
%     '/isin/US81180WAH43','/isin/US74913GAX34','/isin/US279158AL39','/isin/US105756AR10',...
%     '/isin/US00101JAK25','/isin/USP6811TAA36','/isin/USP6040KAB37','/isin/USN54468AD05',...
%     '/isin/USN15516AB83','/isin/US12803X2B68','/isin/USP3579EAH01','/isin/US31572UAF30',...
%     '/isin/USP93077AA61','/isin/USC10602AW79','/isin/XS0833886095',...
%     '/isin/USP09262AA70','/isin/US451102BF38','/isin/USP1905CAD22',...
%     '/isin/US00165AAH14','/isin/US78442FEQ72',...
%     '/isin/USG87264AA81','/isin/US156700AX46','/isin/US17453BAW19','/isin/USP1265VAD49',...
%     '/isin/USG53770AB22','/isin/USN54468AF52','/isin/US02005NAR17','/isin/USP1330HBF03',...
%     '/isin/US25470XAW56',...
%     '/isin/US428040CN71'

%ORIGINAL BONDS FROM JPM MONITOR 
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

%'/isin/US46625HHA14', no maturity year
%'/isin/US060505DR26', no maturity year
%'/isin/USP1265VAA00', no credit rating
%'/isin/US865622BT00', no credit rating
%'/isin/US865622BU72', no credit rating
%'/isin/US056752AC24
%'/isin/USP7169GAA78', extremely low return
%'/isin/USP5880UAB63'
%'/isin/USP989MJAY76
%'/isin/USP46756AH86
%'/isin/USG0457FAC17',
%'/isin/USP7464EAA49'


% sort bonds into usable categories based on minimum piece
A = 1;
B = 1;
C = 1;
D = 1;
E = 1;

[bond_minimum] = getdata(c, full_bonds_list ,'MIN_PIECE');

for i = 1:length(full_bonds_list)
    bond_min = bond_minimum{i,1};
    if bond_min <= 1000
        setA(A,1) = full_bonds_list(1,i);
        A = A + 1;
    elseif bond_min <= 5000
        setB(B,1) = full_bonds_list(1,i);
        B = B + 1;
    elseif bond_min <= 10000
        setC(C,1) = full_bonds_list(1,i);
        C = C + 1;
    elseif bond_min <= 100000;
        setD(D,1) = full_bonds_list(1,i);
        D = D + 1;
    else
        setE(E,1) = full_bonds_list(1,i);
        E = E + 1;
    end
end

clearvars A B C D E
setB = cat(1, setA, setB);
setC = cat(1, setB, setC);
setD = cat(1, setC, setD);
setE = cat(1, setD, setE);

%select usable bonds based on minimum piece
if capital <= 200000
    bonds_list = setA;
elseif capital <= 500000
    bonds_list = setB;
elseif capital <= 1000000
    bonds_list = setC;
elseif capital <= 5000000
    bonds_list = setD;
else
    bonds_list = setE;
end

                                        % GET DATA %
% gets last price, maturity, coupons, tickers, name, currency, and credit rating data
[bonds_cell_array] = history(c, bonds_list ,'LAST_PRICE', startDate, endDate, {'monthly','actual',...
                  'all_calendar_days','nil_value'});
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
    Date(i + 12 * (j - start_year),1) = nweekdate(1, 2, j, i); 
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
%     if strcmp(origin_country_name{i, 1}, 'REPUBLIC OF ARGENTINA') == 1;
%         country_matrix(1,i) = bonds_list(1,i);
        %argentina behaves weird in the code bc of too many NAN values
       J = J + 1; 
    %sort by country    
    if strcmp(origin_country_name{i, 1}, 'BR') == 1; %BRAZIL
        country_matrix(1,i) = 1;
       
    elseif strcmp(origin_country_name{i, 1}, 'CL') == 1; %REPUBLIC OF CHILE      
       country_matrix(2,i) = 1;
       
       %CODELCO IS NOT A COUNTRY IT IS A LARGE MINING COMPANY IN CHILE!
       
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
    
    %sort by rating  
     rating = credit_rating{i,1};
    if (strcmpi(rating,'AAA') | strcmpi(rating,'AA+') | ...
            strcmpi(rating,'AA') | strcmpi(rating,'AA-')) == 1;
        credit_rating_matrix(1,i) = 1;
        
    elseif (strcmpi(rating,'A+') | strcmpi(rating,'A') | ...
            strcmpi(rating,'A-')) == 1;
        credit_rating_matrix(2,i) = 1;
        
    elseif (strcmpi(rating,'BBB+') | strcmpi(rating,'BBB') | ...
            strcmpi(rating,'BBB-')) == 1;
        credit_rating_matrix(3,i) = 1;
        
    elseif (strcmpi(rating,'BB+') | strcmpi(rating,'BB') | ...
            strcmpi(rating,'BB-') | strcmpi(rating,'B+') | strcmpi(rating,'B') | ...
            strcmpi(rating,'B-') | strcmpi(rating,'CCC+') | strcmpi(rating,'CCC') | ...
            strcmpi(rating,'CCC-') | strcmpi(rating,'CC+') | strcmpi(rating,'CC') | ...
            strcmpi(rating,'CC-') | strcmpi(rating,'C+') | strcmpi(rating,'C') | ...
            strcmpi(rating,'C-') | strcmpi(rating,'DDD+') | strcmpi(rating,'DDD') | ...
            strcmpi(rating,'DDD-') | strcmpi(rating,'DD+') | strcmpi(rating,'DD') | ...
            strcmpi(rating,'DD-') | strcmpi(rating,'D+') | strcmpi(rating,'D') | ...
            strcmpi(rating,'D-')) == 1;
        credit_rating_matrix(4,i) = 1;
        
    else
        error('Unable to sort bond by credit rating.');
        
    end
    
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
    
    %sort by currency type
    currency = currency_symbol{i,1};
    if strcmpi(currency,'USD') == 1;
        currency_matrix(1,i) = 1;
%     elseif strcmpi(currency,'BRL') == 1;
%         currency_matrix(2,i) = 1;
%     elseif strcmpi(currency,'ARS') == 1;
%         currency_matrix(3,i) = 1;
    else
%         error('unable to sort bond by currency');
          currency_matrix(2,i) = 1;
    end
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
total_bonds_array = ones(1,length(bonds_list));
bonds_diagonal = blkdiag(size(total_bonds_array));

                                % FINALIZATION %
%close BB connection
close(c)
%save data in .mat file
    %asset will be bond labels, data is bond prices
save('conservativeVariables.mat','Asset','Data','Date', ...
'grouped_bonds_percentage', 'AssetReturns', 'overrideAssets',...
'restoreAssets', 'country_matrix', 'credit_rating_matrix', 'grouped_credit_ratings_percentage',...
'grouped_years_to_maturity_percentage', 'years_to_maturity_matrix', 'grouped_currency_percentage',...
'currency_matrix');
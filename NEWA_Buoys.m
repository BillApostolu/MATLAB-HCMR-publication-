#This script gives the final data of the buoy's and the model's wind speeds in the same height and the same timesteps.
clear
clc
buoy_names = {'IR_TS_MO_ValenciaI-buoy','IR_TS_MO_6100196','IR_TS_MO_6100197',...
    'IR_TS_MO_6100198','IR_TS_MO_6100280','IR_TS_MO_6100281','IR_TS_MO_6100417',...
    'IR_TS_MO_6100430','IR_TS_MO_6101404','IR_TS_MO_Alboran-buoy'};
%model grid
load('F:\WIND_DATA\NEWA_WS_10_mat_files\2005\NEWA_WS_20050101_000000.mat');
model_points = [data_struct.longitude, data_struct.latitude];

%vriskei ola ta NEWA filenames kai krataei ta datetime tous
newa_files = dir('F:\WIND_DATA\NEWA_WS_10_mat_files\**\NEWA_WS_*.mat');
 %Purpose: This line uses the dir function to search for all .mat files in the specified directory and its subdirectories that match the pattern NEWA_WS_*.mat.
 %Explanation: F:\WIND_DATA\NEWA_WS_10_mat_files\**\: The ** wildcard tells MATLAB to search recursively through all subdirectories within the specified path.
 %NEWA_WS_*.mat: The * wildcard matches any filename that starts with NEWA_WS_ and ends with .mat.
 %Output: The dir function returns a structure array (newa_files) where each element corresponds to a file that matches the pattern. 
 %Each element contains fields like name, folder, date, bytes, etc
newa_dates = NaT(length(newa_files), 1, 'Format', 'yyyyMMdd_HHmmss');
 %This creates an array of NaT values with the same length as newa_files.
 %NaT is the datetime equivalent of NaN (Not-a-Number) for numeric arrays.
 % The 'Format' parameter ensures that the datetime array has the correct format as YearMonthDay_HourMinuteSecond (e.g., 20120110_033000)
for i = 1:length(newa_files)
    filename = newa_files(i).name;
    %newa_files(i).name: Accesses the name field of the i-th file in the newa_files structure array
    %Output: filename is a string containing the name of the file (e.g., NEWA_WS_20120110_033000.mat)
    date_str = regexp(filename, '\d{8}_\d{6}', 'match');
    %Purpose: Extracts the date and time portion from the filename using a regular expression.
    %Explanation:regexp(filename, '\d{8}_\d{6}', 'match'): Uses a regular expression to search for a pattern in the filename.
    % \d{8}: Matches exactly 8 digits (representing the date in YYYYMMDD format).
    % _: Matches the underscore character.
    % \d{6}: Matches exactly 6 digits (representing the time in HHMMSS format).
    % 'match': Returns the portion of the filename that matches the pattern.
    % For example, if filename = 'NEWA_WS_20120110_033000.mat', the regular expression will match 20120110_033000.
    % Output: date_str is a cell array containing the matched string (e.g., {'20120110_033000'}).
    newa_dates(i) = datetime(date_str{1}, 'InputFormat', 'yyyyMMdd_HHmmss');
    %Explanation:date_str{1}: Accesses the first (and only) element of the cell array date_str, which is the matched date string (e.g., '20120110_033000').
    %datetime(date_str{1}, 'InputFormat', 'yyyyMMdd_HHmmss'): Converts the string into a datetime object using the specified input format.
end
%Sortarisma
newa_dates = sort(newa_dates);
newa_dates = datetime(newa_dates, 'Format', 'dd-MMM-yyyy HH:mm:ss');
for buoy_idx = 1:length(buoy_names)
    current_buoy = buoy_names{buoy_idx};
    buoypath = sprintf('E:\\HELLENICBUOYS\\%s.nc', current_buoy);

    Blat = ncread(buoypath, 'LATITUDE');
    Blon = ncread(buoypath, 'LONGITUDE');
    Bdepth = ncread(buoypath, 'DEPH');
    Bws = ncread(buoypath, 'WSPD');
    Bflags = ncread(buoypath, 'WSPD_QC');
    t = ncread(buoypath, 'TIME');

    begindate = datetime(1950,1,1);%apo ekei metrane tp xrono se meres me dekadika (18945,847332 meres px) oi shmadoures
    Btime = begindate + t; %datetime typou '2015-01-15 15:00:00'

    % script gia na vroume ta 4 kontynotera shmeia tou grid sto buoy 
    buoy_point = [Blon, Blat];
    distances = pdist2(double(model_points), double(buoy_point));%pdist2(shmeion, shmeioy endiaferontos) vriskei thn apostash metajy 2 shmeion
    [sorted_distances, idx] = sort(distances);%to sort ta vazei apo to mikrotero sto megalytero%idx einai tou pinaka distances ta indexes
    nearest_points = model_points(idx(1:4), :);%pairno mono th x syntetagmenh kai h y akolouthei
    nearest_distances = sorted_distances(1:4);

    %1 loopa gia na doume poio row exei data. An exei parapano apo ena row data tote problhma allazoume kodika.
    valid_row = 0;
    for i = 1:size(Bws, 1) %size(Bws, dim): If dim = 1, returns rows, If dim = 2, returns columns.
        if any(~isnan(Bws(i, :))) % an opoiodhpote kouti exei non-NaN value dialegei auto to row
            valid_row = i;
            break;
        end
    end
    h = Bdepth(valid_row);

    %2 loopa gia afairesh NaN values kai epilogh ton valid timon Bws kai Btime me flag=1 kai non-NaN values
    buoy_ws = Bws(valid_row, :);
    buoy_flags = Bflags(valid_row, :);
    valid_Bws = [];
    valid_Btime = [];
    valid_Bflags = [];
    for i = 1:length(Btime)
        if ~isnan(buoy_ws(i)) && buoy_flags(i) == 1 && ismember(Btime(i), newa_dates)
            valid_Bws = [valid_Bws buoy_ws(i)];
            valid_Btime = [valid_Btime Btime(i)];
            valid_Bflags = [valid_Bflags buoy_flags(i)];
        end
    end

    %3 loopa gia thn euresh ton katallhlon mat files
    nearest_ws = zeros(length(valid_Btime), 4);%array me tis taxythtes kai gia ta 4 shmeia
    for i = 1:length(valid_Btime)
        current_time = valid_Btime(i);
        date_str = datestr(current_time, 'yyyymmdd_HHMMSS');%The datestr function is used to format 
        %the current_time into a string (yyyymmdd_HHMMSS) that matches the NEWA filename format
        filename = sprintf('F:\\WIND_DATA\\NEWA_WS_10_mat_files\\%d\\NEWA_WS_%s.mat', ...
            year(current_time), date_str);
        
        if exist(filename, 'file')%o typos autou pou theloume na vroume thn yparjh eina 'file'
            load(filename);
            pointsws = data_struct.wind_speed(:);
            nearest_ws(i, :) = pointsws(idx(1:4));
        else
            warning('File not found: %s', filename);
            nearest_ws(i, :) = NaN;
        end
    end

    %4 loopa gia kathe timestep gia to shmeio ths shmadouras kai metafora ws
    %buoy sta 10m tou modelou
    final_Bws = zeros(length(valid_Btime), 1);
    UModel = zeros(length(valid_Btime), 1);
    z0 = 0.0001; % tyxaio, de mas endiaferei apaleifetai
    for i = 1:length(valid_Btime)
        % 1h ejisosh stathmismenos mesos oros
        paronomasths = sum(1 ./ nearest_distances.^2);
        arithmitis = 0;
        for j = 1:4
            arithmitis = arithmitis + (nearest_ws(i, j) / nearest_distances(j)^2);
        end
        UModel(i) = arithmitis / paronomasths;
        % 2h ejisosh metafora taxythtas valid_Bws(i) tou buoy sto ypsos tou monteloy sta 10m
        final_Bws(i) = valid_Bws(i) * (log(10 / z0) / log(3 / z0));
    end

    %saves
    start_time = datestr(valid_Btime(1), 'yyyymmdd_HHMM');%datetime gia to buoy filename
    end_time = datestr(valid_Btime(end), 'yyyymmdd_HHMM');
    buoymatfile = sprintf('F:\\WIND_DATA\\Buoys_NEWAmat_files\\%s_%s_%s.mat', ...
        current_buoy, start_time, end_time);%vazo olo to filepath
    final_structNEWA = struct();
    final_structNEWA.longitude = Blon;
    final_structNEWA.latitude = Blat;
    final_structNEWA.date = valid_Btime;
    final_structNEWA.valid_buoy_wind_speed = valid_Bws;
    final_structNEWA.final_heightened_buoy_wind_speed = final_Bws;
    final_structNEWA.coolocated_model_wind_speed = UModel;
    final_structNEWA.flags = valid_Bflags;
    save(buoymatfile, 'final_structNEWA', '-v7.3');
    fprintf('Processed and saved data for buoy: %s\n', current_buoy);
end

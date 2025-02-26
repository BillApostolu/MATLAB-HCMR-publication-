%This script finds all the wind speed data in timesteps for the nearest four points of the NEWA model to each buoy and saves the data to mat files.
clear;
clc;

subdir = "F:\WIND_DATA\NEWA";
output_dir = "F:\WIND_DATA\NEWA_Buoysnearpoints";
buoy_dir = "F:\WIND_DATA\HELLENICBUOYS";

buoy_names = {'MO_TS_MO_SKYRO', 'MO_TS_MO_SARON', 'MO_TS_MO_SANTO', 'MO_TS_MO_MYKON', ...
    'MO_TS_MO_LESVO', 'MO_TS_MO_KALAM', 'MO_TS_MO_HERAKLION', 'MO_TS_MO_68422', ...
    'MO_TS_MO_61277', 'MO_TS_MO_ATHOS', 'MO_TS_MO_ZAKYN','IR_TS_MO_6100196', ...
    'IR_TS_MO_6100197', 'IR_TS_MO_6100198','IR_TS_MO_6100280',...
    'IR_TS_MO_6100281', 'IR_TS_MO_6100417','IR_TS_MO_6100430', 'IR_TS_MO_6101404',...
    'IR_TS_MO_Alboran', 'IR_TS_MO_ValenciaI'};

for year = 2005:2018
    year_dir = fullfile(output_dir, sprintf('%d', year));
    if ~exist(year_dir, 'dir')
        mkdir(year_dir);
        fprintf('Created directory for year %d\n', year);
    end
end

nc_files = dir(fullfile(subdir, 'NEWA_*.nc'));

buoy_locations = struct();
for buoy_idx = 1:length(buoy_names)
    current_buoy = buoy_names{buoy_idx};
    buoypath = sprintf('F:\\WIND_DATA\\HELLENICBUOYS\\%s.nc', current_buoy);
    buoy_locations.(current_buoy).latitude = ncread(buoypath, 'LATITUDE');
    buoy_locations.(current_buoy).longitude = ncread(buoypath, 'LONGITUDE');
end

last_processed_file = 'NEWA_18_08-01_09_2010.nc'; 
start_idx = 1;
for i = 1:length(nc_files)
    if strcmp(nc_files(i).name, last_processed_file)
        start_idx = i + 1; % Start from the next file
        fprintf('Resuming from file index %d (after %s)\n', start_idx, last_processed_file);
        break;
    end
end

fprintf('\nProcessing latitude and longitude data...\n');
first_file = fullfile(subdir, nc_files(1).name);
lon = ncread(first_file, 'XLON');
lat = ncread(first_file, 'XLAT');
lon(lon >= 354 & lon <= 360) = lon(lon >= 354 & lon <= 360) - 360;

valid_points = ~isnan(lat) & ~isnan(lon); 
lat_valid = lat(valid_points);
lon_valid = lon(valid_points); 
valid_indexes = find(valid_points); 

model_points = [lon_valid(:), lat_valid(:)]; 

for file_idx = start_idx:length(nc_files)
    filename = nc_files(file_idx).name;
    fprintf('\nProcessing file: %s\n', filename);
    tic; % Start timer
    filepath = fullfile(subdir, filename);
   
    t = ncread(filepath, 'time');
    timedata = datetime(1989, 1, 1) + minutes(t);
    ws = ncread(filepath, 'WS10'); % 1287x467x720 array
   
    for time_step = 1:length(t)
        data_struct = struct();
        data_struct.date = timedata(time_step);
        data_struct.buoy_names = buoy_names;
        ws_current = ws(:, :, time_step); % 1287x467 array for the current timestep
        ws_current_valid = ws_current(valid_indexes); 
        
        for buoy_idx = 1:length(buoy_names)
            current_buoy = buoy_names{buoy_idx};
            buoy_point = [buoy_locations.(current_buoy).longitude, buoy_locations.(current_buoy).latitude];
            
            distances = pdist2(double(model_points), double(buoy_point));
            [sorted_distances, idx] = sort(distances);
            nearest_points = model_points(idx(1:4), :);
            nearest_distances = sorted_distances(1:4);

            data_struct.(current_buoy).nearest_points = nearest_points;
            data_struct.(current_buoy).nearest_distances = nearest_distances;
            data_struct.(current_buoy).wind_speeds = ws_current_valid(idx(1:4));
        end
      
        current_year = str2double(datestr(timedata(time_step), 'yyyy'));        
        matfilename = sprintf('NEWA_Buoysnearpoints_%s.mat', datestr(timedata(time_step), 'yyyymmdd_HHMMSS'));     
        year_dir = fullfile(output_dir, sprintf('%d', current_year));
        save(fullfile(year_dir, matfilename), 'data_struct', '-v7.3');
    end        
  
    processing_time = toc;
    fprintf('File complete. Total timesteps processed: %d\n', length(t));
    fprintf('Processing time: %.2f seconds\n', processing_time);
end

fprintf('\nComplete!\n');

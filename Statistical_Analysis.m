%StatisticalAnalysis
clear;
clc;

% Define the folder containing the .mat files
folder_path = "F:\WIND_DATA\Buoys_MERRAmat_files";

% Get a list of all .mat files in the folder
mat_files = dir(fullfile(folder_path, '*.mat'));

% Loop through each .mat file
for k = 1:length(mat_files)
    % Load the .mat file
    file_name = mat_files(k).name;
    file_path = fullfile(folder_path, file_name);
    load(file_path, 'data_struct'); % Load the struct from the .mat file
    
    % Extract the relevant data from the struct
    buoy_wind_speed = data_struct.final_heightened_buoy_wind_speed; % In-situ measurements
    model_wind_speed = data_struct.coolocated_model_wind_speed; % Reanalysis model data
    
    % Ensure the data is in column vector format (if not already)
    buoy_wind_speed = buoy_wind_speed(:);
    model_wind_speed = model_wind_speed(:);
    
    % Remove any NaN values (if present) to ensure accurate calculations
    valid_indices = ~isnan(buoy_wind_speed) & ~isnan(model_wind_speed);
    buoy_wind_speed = buoy_wind_speed(valid_indices);
    model_wind_speed = model_wind_speed(valid_indices);
    
    % Number of data points
    n = length(buoy_wind_speed);
    
    % Calculate Root Mean Squared Error (RMSE)
    RMSE = sqrt(sum((buoy_wind_speed - model_wind_speed).^2) / n);
    
    % Calculate Mean Bias Error (MBE)
    MBE = sum(buoy_wind_speed - model_wind_speed) / n;
    
    % Calculate Pearson correlation coefficient (r)
    r = corr(buoy_wind_speed, model_wind_speed);
    
    % Calculate Mean Absolute Error (MAE)
    MAE = sum(abs(buoy_wind_speed - model_wind_speed)) / n;
    
    % Calculate Relative Error (RE)
    RE = 100 * (sum((buoy_wind_speed - model_wind_speed) ./ buoy_wind_speed)) / n;
    
    % Calculate Scatter Index (SI)
    buoy_wind_speed_mean = mean(buoy_wind_speed);
    SI = sqrt(sum((buoy_wind_speed - model_wind_speed - MBE).^2) / n) / buoy_wind_speed_mean;
    
    % Store the results in the existing struct
    data_struct.RMSE = RMSE;
    data_struct.MBE = MBE;
    data_struct.r = r;
    data_struct.MAE = MAE;
    data_struct.RE = RE;
    data_struct.SI = SI;
    
    % Save the updated struct back to the .mat file
    save(file_path, '-struct', 'data_struct');
    
    % Display results for this buoy
    fprintf('Results for file: %s\n', file_name);
    fprintf('  Root Mean Squared Error (RMSE): %.4f\n', RMSE);
    fprintf('  Mean Bias Error (MBE): %.4f\n', MBE);
    fprintf('  Pearson correlation coefficient (r): %.4f\n', r);
    fprintf('  Mean Absolute Error (MAE): %.4f\n', MAE);
    fprintf('  Relative Error (RE): %.4f%%\n', RE);
    fprintf('  Scatter Index (SI): %.4f\n', SI);
    fprintf('\n');
end

fprintf('All files processed and results saved back to the corresponding .mat files.\n');

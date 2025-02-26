%StatisticalAnalysis
clear;
clc;

folder_path = "F:\WIND_DATA\Buoys_MERRAmat_files";
mat_files = dir(fullfile(folder_path, '*.mat'));

for k = 1:length(mat_files)
    file_name = mat_files(k).name;
    file_path = fullfile(folder_path, file_name);
    load(file_path, 'data_struct'); 
    buoy_wind_speed = data_struct.final_heightened_buoy_wind_speed; 
    model_wind_speed = data_struct.coolocated_model_wind_speed;
    buoy_wind_speed = buoy_wind_speed(:);
    model_wind_speed = model_wind_speed(:);
    valid_indices = ~isnan(buoy_wind_speed) & ~isnan(model_wind_speed);
    buoy_wind_speed = buoy_wind_speed(valid_indices);
    model_wind_speed = model_wind_speed(valid_indices);
    n = length(buoy_wind_speed);
    RMSE = sqrt(sum((buoy_wind_speed - model_wind_speed).^2) / n);
    MBE = sum(buoy_wind_speed - model_wind_speed) / n;
    r = corr(buoy_wind_speed, model_wind_speed);
    MAE = sum(abs(buoy_wind_speed - model_wind_speed)) / n;
    RE = 100 * (sum((buoy_wind_speed - model_wind_speed) ./ buoy_wind_speed)) / n;
    buoy_wind_speed_mean = mean(buoy_wind_speed);
    SI = sqrt(sum((buoy_wind_speed - model_wind_speed - MBE).^2) / n) / buoy_wind_speed_mean;
    data_struct.RMSE = RMSE;
    data_struct.MBE = MBE;
    data_struct.r = r;
    data_struct.MAE = MAE;
    data_struct.RE = RE;
    data_struct.SI = SI;
    save(file_path, '-struct', 'data_struct');
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

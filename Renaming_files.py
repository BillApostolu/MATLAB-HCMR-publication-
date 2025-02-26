import os
import re
from pathlib import Path

# Specify the folder path here
FOLDER_PATH = r"E:\MERRA-2"

def rename_merra_files(folder_path):
    """
    Renames MERRA-2 files from MERRA2_number.inst1_2d_lfo_Nx.yyyymmdd.nc4
    to MERRA2.yyyymmdd.nc4 format
    
    Args:
        folder_path (str): Path to the folder containing MERRA-2 files
    """
    # Convert the folder path to Path object for better cross-platform compatibility
    folder = Path(folder_path)
    
    # Regular expression pattern to match the file format and extract date
    pattern = r'MERRA2_\d+\.inst1_2d_lfo_Nx\.(\d{8})\.nc4$'
    
    # Counter for renamed files
    renamed_count = 0
    errors_count = 0
    
    # Iterate through all files in the folder
    for file in folder.glob('*.nc4'):
        match = re.match(pattern, file.name)
        
        if match:
            try:
                # Extract the date part
                date_part = match.group(1)
                
                # Construct new filename
                new_name = f'MERRA2.{date_part}.nc4'
                new_path = file.parent / new_name
                
                # Rename the file
                file.rename(new_path)
                renamed_count += 1
                print(f'Renamed: {file.name} -> {new_name}')
                
            except Exception as e:
                print(f'Error renaming {file.name}: {str(e)}')
                errors_count += 1
    
    # Print summary
    print(f'\nRenaming complete!')
    print(f'Successfully renamed files: {renamed_count}')
    print(f'Errors encountered: {errors_count}')

if __name__ == '__main__':
    rename_merra_files(FOLDER_PATH)

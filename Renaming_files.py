import os
import re
from pathlib import Path

FOLDER_PATH = r"E:\MERRA-2"
def rename_merra_files(folder_path):
    """
    Renames MERRA-2 files from MERRA2_number.inst1_2d_lfo_Nx.yyyymmdd.nc4
    to MERRA2.yyyymmdd.nc4 format
    """
    folder = Path(folder_path)
    pattern = r'MERRA2_\d+\.inst1_2d_lfo_Nx\.(\d{8})\.nc4$'
    renamed_count = 0
    errors_count = 0
    for file in folder.glob('*.nc4'):
        match = re.match(pattern, file.name)
        
        if match:
            try:
                date_part = match.group(1)
                new_name = f'MERRA2.{date_part}.nc4'
                new_path = file.parent / new_name
                file.rename(new_path)
                renamed_count += 1
                print(f'Renamed: {file.name} -> {new_name}')
                
            except Exception as e:
                print(f'Error renaming {file.name}: {str(e)}')
                errors_count += 1
    print(f'\nRenaming complete!')
    print(f'Successfully renamed files: {renamed_count}')
    print(f'Errors encountered: {errors_count}')
if __name__ == '__main__':
    rename_merra_files(FOLDER_PATH)

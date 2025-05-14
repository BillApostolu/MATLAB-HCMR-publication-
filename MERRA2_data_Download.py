#this script directly downloads MERRA-2 data from NASA's database website "https://disc.gsfc.nasa.gov/datasets"
import os
import requests
import urllib.parse
# NASA Earthdata Login Credentials
USERNAME = 'yours'
PASSWORD = 'yours'
def download_file(url, download_dir):
    os.makedirs(download_dir, exist_ok=True)
    session = requests.Session()
    session.auth = (USERNAME, PASSWORD)   
    try:
        parsed_url = urllib.parse.urlparse(url)
        query_params = urllib.parse.parse_qs(parsed_url.query)
        if 'FILENAME' in query_params:
            full_filename = urllib.parse.unquote(query_params['FILENAME'][0])
            filename = os.path.basename(full_filename)
            response = session.get(url, allow_redirects=True)
            if response.status_code == 200:
                filepath = os.path.join(download_dir, filename)
                with open(filepath, 'wb') as f:
                    f.write(response.content)             
                print(f"Successfully downloaded: {filename}")
                return True
            else:
                print(f"Failed to download: {url}")
                print(f"Status code: {response.status_code}")
                return False
        else:
            print(f"No filename found in URL: {url}")
            return False   
    except Exception as e:
        print(f"Error downloading {url}: {e}")
        return False
def main():
    filelist = '1985-2020.txt'  # Your list of URLs
    download_dir = r'E:\MERRA-2'
    with open(filelist, 'r') as f:
        urls = f.read().splitlines()    
    # Download each file
    successful_downloads = 0
    total_urls = len(urls) 
    for url in urls:
        url = url.strip()
        if download_file(url, download_dir):
            successful_downloads += 1
    
    print(f"\nDownload Summary:")
    print(f"Total URLs: {total_urls}")
    print(f"Successfully downloaded: {successful_downloads}")
    print(f"Failed downloads: {total_urls - successful_downloads}")
if __name__ == '__main__':
    main()

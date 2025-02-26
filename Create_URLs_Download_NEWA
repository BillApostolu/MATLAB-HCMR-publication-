#Creates the urls in order to download the data from the NEWA site automatically.
from datetime import datetime, timedelta

# Base URL components
base_url = "https://wps.neweuropeanwindatlas.eu/api/mesoscale-ts/v1/get-data-bbox"
params = {
    "southBoundLatitude": "32.879587",
    "northBoundLatitude": "45.859412",
    "westBoundLongitude": "-6.020508",
    "eastBoundLongitude": "36.298828",
    "variable": "WS10",
}

# Date range configuration
start_date = datetime(2005, 1, 1)
end_date = datetime(2018, 1, 31, 23, 30)
interval_days = 15

# Generate URLs
current_start = start_date
urls = []

while current_start <= end_date:
    # Calculate stop time (current start + 15 days - 30 minutes)
    tentative_stop = current_start + timedelta(days=interval_days) - timedelta(minutes=30)
    
    # Ensure we don't exceed the end date
    final_stop = min(tentative_stop, end_date)
    
    # Format dates for URL
    dt_start = current_start.isoformat()
    dt_stop = final_stop.isoformat()
    
    # Create URL
    url = f"{base_url}?{'&'.join([f'{k}={v}' for k, v in params.items()])}&dt_start={dt_start}&dt_stop={dt_stop}"
    urls.append(url)
    
    # Prepare next interval
    current_start = final_stop + timedelta(minutes=30)

# Save to file
with open('api_urls.txt', 'w') as f:
    for url in urls:
        f.write(url + '\n')

print(f"Successfully generated {len(urls)} URLs in api_urls.txt")

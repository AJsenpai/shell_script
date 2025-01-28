import requests
from requests.auth import HTTPBasicAuth

# Configuration
WORKSPACE = "your-workspace-id"  # Find in Bitbucket URL
USERNAME = "your-email@domain.com"
APP_PASSWORD = "your-app-password"  # Create in Bitbucket settings
SEARCH_STRING = "password="  # String to search
MAX_RESULTS = 100  # Results per page (max 100)

def search_bitbucket_repos():
    auth = HTTPBasicAuth(USERNAME, APP_PASSWORD)
    search_url = f"https://api.bitbucket.org/2.0/workspaces/{WORKSPACE}/search/code"
    
    params = {
        "search_query": f'"{SEARCH_STRING}"',
        "fields": "values.file.commit.repository.slug,values.file.commit.repository.links.html.href,next",
        "pagelen": MAX_RESULTS
    }

    matched_repos = set()
    
    while True:
        response = requests.get(search_url, auth=auth, params=params)
        
        if response.status_code != 200:
            print(f"Error: {response.status_code} - {response.text}")
            break
            
        data = response.json()
        
        # Extract unique repositories
        for result in data.get('values', []):
            repo = result['file']['commit']['repository']
            repo_info = (repo['slug'], repo['links']['html']['href'])
            matched_repos.add(repo_info)
        
        # Pagination handling
        if 'next' in data:
            search_url = data['next']
        else:
            break

    # Print results
    if matched_repos:
        print(f"Found '{SEARCH_STRING}' in {len(matched_repos)} repositories:")
        for idx, (slug, url) in enumerate(matched_repos, 1):
            print(f"{idx}. {slug} - {url}")
    else:
        print("No matching repositories found")

if __name__ == "__main__":
    search_bitbucket_repos()

from time import sleep
import requests
import json
import random

def validate_subreddits(subreddit_list):
    """
    Validate a list of subreddits by checking if they exist on Reddit.
    """
    url = "https://www.reddit.com/r/{}/about/rules.json?raw_json=1"
    valid_subreddit = []
    error_subreddit = []
    headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36"
    }
    tot = len(subreddit_list)
    for i in range(tot):
        sr = subreddit_list[i]
        try:
            print(url.format(sr))
            response = requests.get(url.format(sr),headers=headers)
            response.raise_for_status()
            if response.status_code == 429:
                error_subreddit.append(sr)
                print(sr)

            if response.json().get('rules', None):
                valid_subreddit.append(sr)
            print(f"{i + 1} of {tot} subreddits validated")
            sleep(2)
        except Exception as e:
            print(f"Error: {e}")
    
    print(f"\n\nError subreddits: {json.dumps(error_subreddit)}\n\n")
    return valid_subreddit


if __name__ == "__main__":
    path = "input.json"
    with open(path,'r') as f:
        subreddits = json.load(f)
    valid_subreddits = validate_subreddits(subreddits)
    valid_subreddits = json.dumps(valid_subreddits)
    print(f"Valid subreddits: {valid_subreddits}")
    with open("active_reddits.json",'w') as f:
        f.write(valid_subreddits)
        
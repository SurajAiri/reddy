import json

def main():
    # Open and read the data from file.json
    with open('duplicate.json', 'r') as file:
        data = json.load(file)
    
    # Convert the list to a set to remove duplicates
    unique_data = list(set(data))
    
    # Write the unique data to final.json
    with open('final.json', 'w') as outfile:
        json.dump(unique_data, outfile, indent=4)

if __name__ == "__main__":
    main()
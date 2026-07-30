import json

def clean_text(text):
    # Remove leading/trailing whitespaces and new lines
    return text.strip()

def newLinePreprocessing(path):
    # Open the file
    with open('test.txt', 'r') as file:
        # Read the content
        content = file.read()
    
    # Split the content by double new lines
    parts = content.split('\n\n')
    
    # Clean each part and filter out empty ones
    parts = [clean_text(part) for part in parts if clean_text(part)]

    
    # Convert the list to a set to remove duplicates
    unique_data = list(set(parts))
    
    # Write the unique data to final.json
    with open('final.json', 'w') as outfile:
        json.dump(unique_data, outfile, indent=4)


def removeDuplicates(path,save_path='final.json'):
    # Open and read the data from file.json
    with open(path, 'r') as file:
        data = json.load(file)
    
    # Convert the list to a set to remove duplicates
    unique_data = list(set(data))

    # unique_data.sort(key=lambda x: x.lower())
    #  lower case each value and then sort
    unique_data.sort(key=lambda x: x.lower())
    
    # Write the unique data to final.json
    with open(save_path, 'w') as outfile:
        json.dump(unique_data, outfile, indent=4)

def main():
    # newLinePreprocessing('test.txt')
    removeDuplicates('duplicate.json')
    

if __name__ == "__main__":
    main()

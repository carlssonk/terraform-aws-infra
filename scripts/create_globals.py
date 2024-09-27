import sys
import json

def main():
    data = {}

    for arg in sys.argv[1:]:
        key, value = arg.split('=')
        data[key] = value

    with open('globals.json', 'w') as json_file:
        json.dump(data, json_file, indent=4)

    print("JSON file 'globals.json' has been created successfully.")

if __name__ == "__main__":
    main()
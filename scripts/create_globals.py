import sys
import json

def parse_key_value(arg):
    key, value = arg.split('=', 1)
    return key.strip(), value.strip().strip('"')

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename> [key1=value1] [key2=value2] ...")
        sys.exit(1)

    filename = sys.argv[1]
    input_pairs = dict(parse_key_value(arg) for arg in sys.argv[2:])

    file_pairs = {}
    try:
        with open(filename, 'r') as file:
            for line in file:
                key, value = parse_key_value(line.strip())
                file_pairs[key] = value
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        sys.exit(1)

    # Merge file pairs and input pairs, with input pairs taking precedence
    merged_pairs = {**file_pairs, **input_pairs}

    output_filename = 'globals.json'
    with open(output_filename, 'w') as outfile:
        json.dump(merged_pairs, outfile, indent=2)

    print(f"Merged key-value pairs have been written to {output_filename}")

if __name__ == "__main__":
    main()
import sys
import json

def parse_key_value(arg):
    key, value = arg.split('=', 1)
    return key.strip(), value.strip().strip('"')

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py [key1=value1] [key2=value2] ...")
        sys.exit(1)

    input_pairs = dict(parse_key_value(arg) for arg in sys.argv[1:])

    output_filename = 'globals.json'
    with open(output_filename, 'w') as outfile:
        json.dump({**input_pairs}, outfile, indent=2)

    print(f"Merged key-value pairs have been written to {output_filename}")

if __name__ == "__main__":
    main()
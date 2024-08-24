import json
import sys

def remove_prefix(key):
    if key.startswith('TF_VAR_'):
        return key[7:]
    if key.startswith('AWS_'):
        return key[4:]
    return key

def merge_json_with_args(env_json, additional_args):
    env_dict = json.loads(env_json)
    
    for arg in additional_args:
        key, value = arg.split('=')
        env_dict[key] = value

    # Remove 'TF_VAR_' and 'AWS_' prefix from existing keys in env_dict
    cleaned_env_dict = {}
    for key, value in env_dict.items():
        cleaned_key = remove_prefix(key)
        cleaned_env_dict[cleaned_key] = value
    
    return cleaned_env_dict

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py '<json>' [key1=value1 key2=value2 ...]")
        sys.exit(1)
    
    env_json = sys.argv[1]
    additional_args = sys.argv[2:]
    
    result = merge_json_with_args(env_json, additional_args)
    
    with open('globals.json', 'w') as f:
        json.dump(result, f, indent=2)
    
    print("Merged JSON has been written to globals.json")

if __name__ == "__main__":
    main()
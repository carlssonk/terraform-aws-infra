import json
import sys

def remove_prefix(key):
    if key.startswith('TF_VAR_'):
        return key[7:]
    return key

def clean_value(value):
    if isinstance(value, str):
        return value.replace(' ', '')
    return value

def merge_json_with_args(env_json, additional_args):
    env_dict = json.loads(env_json)
    
    for arg in additional_args:
        key, value = arg.split('=')
        env_dict[key] = value

    
    cleaned_env_dict = {}
    for key, value in env_dict.items():
        cleaned_key = remove_prefix(key) # Remove 'TF_VAR_' prefix from existing keys in env_dict
        cleaned_env_dict[cleaned_key] = clean_value(value)
    
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
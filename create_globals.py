import json
import sys

def remove_tf_var_prefix(key):
    if key.startswith('TF_VAR_'):
        return key[7:]
    return key

def merge_json_with_args(env_json, additional_args):
    # Parse the env_json string into a Python dictionary
    env_dict = json.loads(env_json)
    
    # Merge additional arguments into the dictionary
    for arg in additional_args:
        key, value = arg.split('=')
        env_dict[key] = value

    # Remove 'TF_VAR_' prefix from existing keys in env_dict
    cleaned_env_dict = {}
    for key, value in env_dict.items():
        cleaned_key = remove_tf_var_prefix(key)
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
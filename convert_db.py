import re

file_path = r'g:\wow-addons\soulbind-cache-opener-continued\SoulbindCacheOpenerContinued\SoulbindCacheOpenerItemDb.lua'

def convert_db():
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        new_lines = []
        id_pattern = re.compile(r'\["id"\]\s*=\s*(\d+)')
        
        for line in lines:
            # Check if line has an ID definition
            match = id_pattern.search(line)
            if match:
                item_id = match.group(1)
                # Replace the first occurrence of '{' with '[item_id] = {'
                # This works for lines like: { ... ["id"] = 123 ... }
                # And transforms to: [123] = { ... ["id"] = 123 ... }
                new_line = line.replace('{', f'[{item_id}] = {{', 1)
                new_lines.append(new_line)
            else:
                new_lines.append(line)
                
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
            
        print("Successfully converted ItemDB to hashmap format.")
        
    except Exception as e:
        print(f"Error converting DB: {e}")

if __name__ == "__main__":
    convert_db()

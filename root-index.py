import os
import re

def title_case(text):
    # Replaces underscores with spaces and capitalizes each word properly
    clean_text = text.replace('_', ' ')
    return re.sub(r'\w+', lambda m: m.group(0).capitalize(), clean_text)

def generate_root_document_index():
    root_dir = os.getcwd()
    content_dir = os.path.join(root_dir, 'content')
    
    if not os.path.exists(content_dir):
        print(f"Error: 'content' folder not found in {root_dir}")
        return

    # Scan only the immediate top-level directories inside content/
    subfolders = []
    try:
        for item in os.listdir(content_dir):
            item_path = os.path.join(content_dir, item)
            if os.path.isdir(item_path):
                # Filter out standard non-index structural names
                if item.lower() not in ['doc', 'docs', 'pdf']:
                    subfolders.append(item)
    except Exception as e:
        print(f"Error reading directory: {e}")
        return

    # Sort them alphabetically to maintain a clean layout structure
    subfolders.sort()

    # Start constructing the string block matching your exact HTML layout classes
    html_fragment = '\n<div id="documents" class="section">\n'
    html_fragment += '    <h2>Document Index</h2>\n'
    html_fragment += '    <div class="index-grid">\n'

    for folder in subfolders:
        clean_title = title_case(folder)
        
        # Maps the local relative destination index path structure cleanly
        href_link = f"index/{folder}/index.html"
        
        html_fragment += f'        <div class="index-card">\n'
        html_fragment += f'            <h3><a href="{href_link}">{clean_title}</a></h3>\n'
        html_fragment += f'            <p>Explore analytical maps and publications inside {clean_title}.</p>\n'
        html_fragment += f'        </div>\n'

    html_fragment += '    </div>\n</div>'

    # Save the generated component block to a text file for easy copy-pasting
    output_filename = "document_index_fragment.html"
    with open(output_filename, 'w', encoding='utf-8') as f:
        f.write(html_fragment)

    print(f"Success! The HTML fragment has been compiled into '{output_filename}'")
    print("\nPreview of generated code:\n" + "-"*40)
    print(html_fragment)

if __name__ == "__main__":
    generate_root_document_index()
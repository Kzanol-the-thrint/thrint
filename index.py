import os
import re
import shutil

def title_case(text):
    # Replaces underscores with spaces and capitalizes each word properly
    clean_text = text.replace('_', ' ')
    return re.sub(r'\w+', lambda m: m.group(0).capitalize(), clean_text)

def generate_indices():
    root_dir = os.getcwd()
    content_dir = os.path.join(root_dir, 'content')
    index_dir = os.path.join(root_dir, 'index')

    if not os.path.exists(content_dir):
        print(f"Error: 'content' folder not found in {root_dir}")
        return

    # Clear out the old index repository folder completely
    if os.path.exists(index_dir):
        shutil.rmtree(index_dir)
    os.makedirs(index_dir)

    print("Mirroring structure and generating clean index.html tracks via Python...")

    # Recursively walk through the content directory
    for current_src_dir, dirs, files in os.walk(content_dir):
        
        # Skip internal system folders or the actual utility 'pdf' folders themselves
        folder_name = os.path.basename(current_src_dir).lower()
        if folder_name in ['doc', 'docs', 'pdf']:
            continue

        # Determine relative path from content root
        rel_path = os.path.relpath(current_src_dir, content_dir)
        if rel_path == '.':
            rel_path = ''

        # Map destination path inside index/
        target_dest_dir = os.path.join(index_dir, rel_path)
        os.makedirs(target_dest_dir, exist_ok=True)

        # Account for the 'index/' folder level itself (+1 depth) to step back out to root safely
        depth = 0 if not rel_path else len(rel_path.split(os.sep))
        dots_to_root = "../" * (depth + 1)
        
        css_path = f"{dots_to_root}stylesheet.css"
        home_path = f"{dots_to_root}index.html"

        # Determine dynamic "One Level Up / Back" pathing rules
        if not rel_path:
            # At index root, going up one level sends user back to global site index.html
            back_path = "../index.html"
            back_link_html = f'<div class="back-link" style="max-width: 1100px; margin: 20px auto 0 auto; padding: 0 20px;"><a href="{back_path}" style="text-decoration: none; color: var(--accent); font-weight: 500;">← Back to Main Hub</a></div>'
        else:
            # Inside subcategories, moving up means going to parent index.html node
            back_path = "../index.html"
            back_link_html = f'<div class="back-link" style="max-width: 1100px; margin: 20px auto 0 auto; padding: 0 20px;"><a href="{back_path}" style="text-decoration: none; color: var(--accent); font-weight: 500;">← Back to Parent Category</a></div>'

        # Determine structural folder title
        if not rel_path:
            clean_title = "Knowledge Hub Root"
        else:
            clean_title = title_case(os.path.basename(current_src_dir))

        # Start drafting the HTML document layout
        html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{clean_title} | Sagar Rajen Kapadia</title>
    <link rel="stylesheet" href="{css_path}">
</head>
<body>
    <header>
        <div class="hero">
            <h1>Sagar Rajen Kapadia</h1>
            <p class="tagline">Researcher • Strategic Analyst • Civilizational Observer</p>
        </div>
    </header>
    <nav>
        <div class="nav-container">
            <div class="nav-logo" style="font-weight:700; font-size:1.4rem; color:var(--primary);">SKX360</div>
            <ul class="nav-links">
                <li><a href="{home_path}">Home</a></li>
            </ul>
        </div>
    </nav>
    
    {back_link_html}

    <main>
        <section class="section">
            <h2>{clean_title} Index</h2>
"""

        # Look for the target 'pdf' subfolder inside the current source directory
        pdf_dir = os.path.join(current_src_dir, 'pdf')
        if os.path.exists(pdf_dir):
            pdf_files = [f for f in os.listdir(pdf_dir) if f.lower().endswith('.pdf')]
            if pdf_files:
                html_content += """            <div class="index-grid">\n"""
                
                for pdf in pdf_files:
                    pdf_name_no_ext = os.path.splitext(pdf)[0]
                    clean_pdf_title = title_case(pdf_name_no_ext)
                    
                    # Map the link from index/path/to/folder/index.html back to content/path/to/folder/pdf/filename.pdf
                    if not rel_path:
                        file_web_link = f"../content/pdf/{pdf}"
                    else:
                        normalized_rel = rel_path.replace(os.sep, '/')
                        file_web_link = f"{dots_to_root}content/{normalized_rel}/pdf/{pdf}"

                    html_content += f"""                <div class="index-card">
                    <h3><a href="{file_web_link}" target="_blank">{clean_pdf_title}</a></h3>
                    <p>Strategic research publication format.</p>
                </div>\n"""
                html_content += """            </div>\n"""

        # Ignore all custom/leaf sibling folders other than 'pdf' for routing deep categories
        subfolders = [d for d in dirs if d.lower() not in ['doc', 'docs', 'pdf']]
        if subfolders:
            html_content += """            <h3 style="color:#0a3d62; margin-top: 40px;">Topics</h3>\n"""
            html_content += """            <div class="index-grid">\n"""
            
            for sub in sorted(subfolders):
                clean_sub_title = title_case(sub)
                html_content += f"""                <div class="index-card">
                    <h3><a href="{sub}/index.html">{clean_sub_title}</a></h3>
                    <p>Explore analytical maps inside {clean_sub_title}.</p>
                </div>\n"""
            html_content += """            </div>\n"""

        # Wrap up the closing document layout blocks
        html_content += f"""        </section>
    </main>
    <footer>
        <p>© 2026 Sagar Rajen Kapadia • Cloud Nine Consulting • Surat, Gujarat, India</p>
    </footer>
</body>
</html>"""

        # Write out the completed index.html safely
        output_file_path = os.path.join(target_dest_dir, 'index.html')
        with open(output_file_path, 'w', encoding='utf-8') as f:
            f.write(html_content)

    print("\nComplete! All index templates processed cleanly.")

if __name__ == "__main__":
    generate_indices()
# Petfolio Hugo Site

This is the Hugo static site for the Petfolio project, deployed to GitHub Pages at [https://jeffreyperdue.github.io/ase-456-individual-project/](https://jeffreyperdue.github.io/ase-456-individual-project/).

## Local Development

To run the site locally:

1. Install Hugo (extended version):
   ```bash
   # On Windows with Chocolatey
   choco install hugo-extended
   
   # Or download from https://gohugo.io/installation/
   ```

2. Navigate to the hugo-site directory:
   ```bash
   cd hugo-site
   ```

3. Start the development server:
   ```bash
   hugo server
   ```

4. Open your browser to `http://localhost:1313`

## Building for Production

To build the site:

```bash
cd hugo-site
hugo --minify
```

The generated site will be in the `public/` directory.

## Deployment

The site is automatically deployed to GitHub Pages via GitHub Actions when changes are pushed to the `main` branch in the `hugo-site/` directory.

The workflow file is located at `.github/workflows/hugo.yml`.

## Project Structure

```
hugo-site/
├── content/          # Markdown content files
├── themes/           # Hugo theme (petfolio-theme)
├── static/           # Static files (PDFs, images, etc.)
│   └── pdfs/         # PDF documents
├── hugo.toml         # Hugo configuration
└── README.md         # This file
```

## Adding New Content

1. Create a new markdown file in `content/` directory
2. Add front matter with title, description, etc.
3. The page will be automatically available at `/filename/`

## PDFs

PDFs are stored in `static/pdfs/` and can be referenced in content as `/pdfs/filename.pdf`.

Current PDFs:
- `project_progress.marp.pdf` - Project progress report
- `system_design_architecture.marp.pdf` - System architecture documentation
- `user_guide.marp.pdf` - User guide
- `final_presentation.marp.pdf` - Final presentation

## Theme

The site uses a custom theme (`petfolio-theme`) located in `themes/petfolio-theme/`. The theme includes:
- Responsive design
- Modern CSS styling
- Navigation menu
- Feature cards
- Documentation pages

## Configuration

Main configuration is in `hugo.toml`. Key settings:
- `baseURL`: GitHub Pages URL
- `theme`: Theme name
- `menu`: Navigation menu items


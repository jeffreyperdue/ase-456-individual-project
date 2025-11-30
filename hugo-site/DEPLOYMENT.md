# Deployment Guide

## GitHub Pages Setup

To deploy this Hugo site to GitHub Pages:

### 1. Enable GitHub Pages

1. Go to your repository settings on GitHub
2. Navigate to **Pages** in the left sidebar
3. Under **Source**, select **GitHub Actions**
4. Save the settings

### 2. GitHub Actions Workflow

The workflow file (`.github/workflows/hugo.yml`) is already configured and will:
- Build the Hugo site when changes are pushed to `main` branch
- Deploy to GitHub Pages automatically
- Use the `hugo-site/` directory as the working directory

### 3. First Deployment

After enabling GitHub Actions as the source:
1. Push any changes to the `hugo-site/` directory
2. The workflow will trigger automatically
3. Check the **Actions** tab to see the build progress
4. Once complete, your site will be available at:
   `https://jeffreyperdue.github.io/ase-456-individual-project/`

### 4. Manual Deployment

You can also trigger a manual deployment:
1. Go to the **Actions** tab
2. Select **Deploy Hugo Site to GitHub Pages**
3. Click **Run workflow**

### 5. Troubleshooting

- **Build fails**: Check the Actions logs for errors
- **Site not updating**: Ensure you're pushing to the `main` branch
- **PDFs not loading**: Verify PDFs are in `hugo-site/static/pdfs/`
- **404 errors**: Check that `baseURL` in `hugo.toml` matches your GitHub Pages URL

### 6. Local Testing

Before deploying, test locally:
```bash
cd hugo-site
hugo server
```
Visit `http://localhost:1313` to preview the site.

### 7. Custom Domain (Optional)

If you want to use a custom domain:
1. Add a `CNAME` file in `hugo-site/static/` with your domain
2. Update DNS settings as per GitHub Pages documentation
3. Update `baseURL` in `hugo.toml` to match your custom domain


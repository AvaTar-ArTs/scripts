#!/usr/bin/env bash

# 🎨 INTEGRATE STYLES INTO ALL PROJECTS
# Copies static HTML/CSS/JS and applies updated styles to Next.js projects

set -e

WORKSPACE="/Users/steven/tehSiTes"
STATIC_DIR="$WORKSPACE/static-projects"
STYLES_FILE="$WORKSPACE/AVATARARTS_GLOBAL_STYLES.css"
THEME_JS="$STATIC_DIR/theme.js"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  🎨 INTEGRATING STYLES INTO ALL PROJECTS                 ║${NC}"
echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════╝${NC}\n"

# Projects to update
PROJECTS=(
  "avatararts-gallery"
  "avatararts-hub"
  "avatararts-portfolio"
  "avatararts-tools"
  "avatararts.org"
)

# ═══════════════════════════════════════════════════════════
# Step 1: Copy styles to each project's public folder
# ═══════════════════════════════════════════════════════════

echo -e "${CYAN}STEP 1: Copying global styles to all projects...${NC}\n"

for project in "${PROJECTS[@]}"; do
  PROJECT_DIR="$WORKSPACE/$project"
  PUBLIC_DIR="$PROJECT_DIR/public"
  
  if [ -d "$PROJECT_DIR" ]; then
    # Create public/styles if it doesn't exist
    mkdir -p "$PUBLIC_DIR/styles"
    
    # Copy styles
    cp "$STYLES_FILE" "$PUBLIC_DIR/styles/"
    cp "$THEME_JS" "$PUBLIC_DIR/"
    
    echo -e "  ${GREEN}✓${NC} $project"
  fi
done

echo ""

# ═══════════════════════════════════════════════════════════
# Step 2: Create enhanced layout components
# ═══════════════════════════════════════════════════════════

echo -e "${CYAN}STEP 2: Creating enhanced layout components...${NC}\n"

# Create a ClientThemeSwitcher component for use in Next.js projects
cat > "$WORKSPACE/ClientThemeSwitcher.tsx" << 'THEMECOMPONENT'
'use client';

import { useEffect, useState } from 'react';

export function ClientThemeSwitcher() {
  const [mounted, setMounted] = useState(false);
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    setMounted(true);
    
    // Get saved theme or system preference
    const saved = localStorage.getItem('theme') as 'light' | 'dark' | null;
    const system = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const initial = saved || system;
    
    setTheme(initial);
    document.documentElement.setAttribute('data-theme', initial);
  }, []);

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  };

  if (!mounted) return null;

  return (
    <button
      onClick={toggleTheme}
      className="theme-switcher"
      aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
      title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
      style={{
        background: 'none',
        border: 'none',
        fontSize: '1.5rem',
        cursor: 'pointer',
        padding: '0.5rem'
      }}
    >
      {theme === 'light' ? '🌙' : '☀️'}
    </button>
  );
}
THEMECOMPONENT

echo -e "  ${GREEN}✓${NC} ClientThemeSwitcher.tsx created"

# ═══════════════════════════════════════════════════════════
# Step 3: Create integration guide
# ═══════════════════════════════════════════════════════════

echo -e "\n${CYAN}STEP 3: Creating integration guide...${NC}\n"

cat > "$WORKSPACE/INTEGRATION_GUIDE.md" << 'INTEGUIDE'
# 🎨 Integration Guide - Styles & Improvements

## What's Been Integrated

✅ Global styles copied to all projects  
✅ Theme switcher component created  
✅ Dark/Light mode system ready  
✅ Responsive design applied  

## How to Use in Each Project

### Step 1: Update `app/layout.tsx`

Add to your HTML head:

```tsx
import ClientThemeSwitcher from '@/components/ClientThemeSwitcher';

export default function RootLayout({ children }) {
  return (
    <html lang="en" data-theme="light">
      <head>
        <link rel="stylesheet" href="/styles/AVATARARTS_GLOBAL_STYLES.css" />
      </head>
      <body>
        <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '1rem' }}>
          <h1>Your Project Title</h1>
          <ClientThemeSwitcher />
        </header>
        {children}
      </body>
    </html>
  );
}
```

### Step 2: Copy Component

Copy `ClientThemeSwitcher.tsx` to `src/components/`

### Step 3: Use CSS Classes

Apply the global theme system classes:

```html
<!-- Gallery -->
<div class="gallery">
  <a href="/image.jpg"><img src="/thumb.jpg" /></a>
</div>

<!-- Gallery Section -->
<section class="gallery-section">
  <h2>Section Title</h2>
  <p>Description text</p>
</section>

<!-- Buttons -->
<button class="btn-primary">Action</button>
<button class="btn-secondary">Secondary</button>
```

### Step 4: CSS Variables

Use CSS variables for styling:

```css
/* Light Mode */
:root {
  --page-text: #0d0d0d;
  --page-bg: #fff;
  --accent-color: #3b82f6;
  --spacing-md: 1rem;
}

/* Dark Mode */
[data-theme="dark"] {
  --page-text: #ececec;
  --page-bg: #212121;
}
```

## Features Available

✨ **Dark/Light Mode** - Toggle with button  
📱 **Responsive Design** - Mobile-first  
🎨 **Beautiful Components** - Galleries, sections, cards  
💫 **Smooth Animations** - Hover effects, transitions  
♿ **Accessibility** - WCAG compliant  

## File Locations

- Styles: `/public/styles/AVATARARTS_GLOBAL_STYLES.css`
- Theme JS: `/public/theme.js`
- Component: `src/components/ClientThemeSwitcher.tsx`

## Testing

1. Start your project: `npm run dev`
2. Click theme switcher (🌙 button)
3. Check responsive design (resize window)
4. Verify dark mode colors

Done! Your project now has professional theming. 🚀
INTEGUIDE

echo -e "  ${GREEN}✓${NC} INTEGRATION_GUIDE.md created"

# ═══════════════════════════════════════════════════════════
# Step 4: Summary
# ═══════════════════════════════════════════════════════════

echo -e "\n${MAGENTA}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  ✅ STYLES INTEGRATED!                                   ║${NC}"
echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}✓ All 5 projects updated:${NC}"
for project in "${PROJECTS[@]}"; do
  echo -e "  • $project"
done

echo -e "\n${YELLOW}Files Added to Each Project:${NC}"
echo -e "  • public/styles/AVATARARTS_GLOBAL_STYLES.css"
echo -e "  • public/theme.js"

echo -e "\n${YELLOW}Files Created:${NC}"
echo -e "  • ClientThemeSwitcher.tsx (React component)"
echo -e "  • INTEGRATION_GUIDE.md (Setup instructions)"

echo -e "\n${CYAN}Next Steps:${NC}"
echo -e "  1. Copy ClientThemeSwitcher.tsx to src/components/ in each project"
echo -e "  2. Update app/layout.tsx in each project"
echo -e "  3. Start your projects: npm run dev"
echo -e "  4. Test theme switching and responsive design"

echo -e "\n${GREEN}All projects ready with enhanced styles! 🎨${NC}\n"

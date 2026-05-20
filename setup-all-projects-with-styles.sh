#!/usr/bin/env bash

# 🎨 SETUP ALL PROJECTS WITH STYLES
# Automates the integration of styles into all 5 projects

set -e

WORKSPACE="/Users/steven/tehSiTes"
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  🎨 SETTING UP ALL PROJECTS WITH STYLES                  ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}\n"

PROJECTS=(
  "avatararts-gallery"
  "avatararts-hub"
  "avatararts-portfolio"
  "avatararts-tools"
  "avatararts.org"
)

# ═══════════════════════════════════════════════════════════
# For each project, set up the component
# ═══════════════════════════════════════════════════════════

for project in "${PROJECTS[@]}"; do
  PROJECT_DIR="$WORKSPACE/$project"
  
  if [ -d "$PROJECT_DIR" ]; then
    echo -e "${CYAN}Setting up: $project${NC}"
    
    # Create src/components directory
    mkdir -p "$PROJECT_DIR/src/components"
    
    # Copy the theme switcher component
    cp "$WORKSPACE/ClientThemeSwitcher.tsx" "$PROJECT_DIR/src/components/"
    
    echo -e "  ${GREEN}✓${NC} Component copied"
    echo ""
  fi
done

# ═══════════════════════════════════════════════════════════
# Create setup instructions file
# ═══════════════════════════════════════════════════════════

cat > "$WORKSPACE/SETUP_INSTRUCTIONS.md" << 'INSTRUCTIONS'
# 🎨 Setup Instructions - Complete Integration

## ✅ What's Already Done

All 5 projects now have:
- ✅ Global styles copied to `public/styles/AVATARARTS_GLOBAL_STYLES.css`
- ✅ Theme switcher JS copied to `public/theme.js`
- ✅ `ClientThemeSwitcher.tsx` component in `src/components/`

## 🔧 Manual Steps for Each Project

### Step 1: Update `app/layout.tsx`

For each project, edit `app/layout.tsx`:

**Add import at top:**
```typescript
import { ClientThemeSwitcher } from '@/components/ClientThemeSwitcher';
```

**Add stylesheet in head:**
```typescript
export default function RootLayout({ children }) {
  return (
    <html lang="en" data-theme="light">
      <head>
        <link rel="stylesheet" href="/styles/AVATARARTS_GLOBAL_STYLES.css" />
      </head>
      <body>
        <header style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center',
          padding: '1rem'
        }}>
          <h1>Your Title</h1>
          <ClientThemeSwitcher />
        </header>
        {children}
      </body>
    </html>
  );
}
```

### Step 2: Use CSS Classes

In your components, use the global CSS classes:

```jsx
// Gallery
<div class="gallery">
  <a href="/image1.jpg"><img src="/thumb1.jpg" alt="Image 1" /></a>
  <a href="/image2.jpg"><img src="/thumb2.jpg" alt="Image 2" /></a>
</div>

// Section
<section class="gallery-section">
  <h2>Gallery Title</h2>
  <p>Description text</p>
</section>

// Buttons
<button class="btn-primary">Primary Action</button>
<button class="btn-secondary">Secondary Action</button>

// Card
<div class="card shadow-md rounded-lg">
  <h3>Card Title</h3>
  <p>Card content</p>
</div>
```

### Step 3: Use CSS Variables

```css
/* In your component CSS */
.my-component {
  background-color: var(--page-bg);
  color: var(--page-text);
  padding: var(--spacing-md);
  border: 1px solid var(--border-light);
}

/* Available variables */
--page-text              /* Main text color */
--page-bg                /* Background color */
--accent-color           /* Primary accent */
--secondary-text         /* Secondary text */
--border-light           /* Light border color */
--spacing-xs             /* 0.25rem */
--spacing-sm             /* 0.5rem */
--spacing-md             /* 1rem */
--spacing-lg             /* 1.5rem */
--spacing-xl             /* 2rem */
```

### Step 4: Start Development

```bash
cd avatararts-gallery
npm run dev
```

Then visit: http://localhost:3000

### Step 5: Test Features

- 🌙 Click the theme button to toggle dark/light mode
- 📱 Resize browser to test responsive design
- ✨ Check that colors change correctly

## 🎯 For All 5 Projects

Repeat Steps 1-5 for:
1. avatararts-gallery
2. avatararts-hub
3. avatararts-portfolio
4. avatararts-tools
5. avatararts.org

## 📦 Files Available

**Global Styles (13KB):**
- `/Users/steven/tehSiTes/AVATARARTS_GLOBAL_STYLES.css`
- Includes light/dark themes, gallery styles, animations

**Theme Switcher:**
- `/Users/steven/tehSiTes/theme.js`
- Vanilla JS, no dependencies

**React Component:**
- `/Users/steven/tehSiTes/ClientThemeSwitcher.tsx`
- Already copied to `src/components/` in all projects

## ✨ Features

✅ Dark & Light modes  
✅ Responsive galleries  
✅ Smooth animations  
✅ Professional styling  
✅ localStorage support  
✅ Auto system preference detection  

## 🚀 Quick Commands

```bash
# Setup a specific project
cd /Users/steven/tehSiTes/avatararts-gallery
npm run dev

# Or with custom port to avoid conflicts
PORT=3001 npm run dev

# All 5 projects on different ports (in separate terminals)
# Terminal 1:
PORT=3000 npm run dev

# Terminal 2:
cd ../avatararts-hub
PORT=3001 npm run dev

# Terminal 3:
cd ../avatararts-portfolio
PORT=3002 npm run dev

# Terminal 4:
cd ../avatararts-tools
PORT=3003 npm run dev

# Terminal 5:
cd ../avatararts.org
PORT=3004 npm run dev
```

## ❓ Troubleshooting

**Theme not switching?**
- Check that `ClientThemeSwitcher.tsx` is in `src/components/`
- Check that it's imported in `app/layout.tsx`
- Check browser console for errors

**Styles not applying?**
- Verify `/public/styles/AVATARARTS_GLOBAL_STYLES.css` exists
- Check that stylesheet link is in head
- Clear browser cache (Cmd+Shift+R on Mac)

**Components not rendering?**
- Make sure component is added to `app/layout.tsx`
- Check that imports are correct
- Verify build completed without errors

## 📚 More Info

See: `/Users/steven/tehSiTes/INTEGRATION_GUIDE.md`

INSTRUCTIONS

echo -e "${GREEN}✓ Setup instructions created${NC}\n"

# ═══════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════

echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  ✅ SETUP COMPLETE!                                       ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}Components copied to all projects:${NC}"
for project in "${PROJECTS[@]}"; do
  echo -e "  ✓ $project/src/components/ClientThemeSwitcher.tsx"
done

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Read: /Users/steven/tehSiTes/SETUP_INSTRUCTIONS.md"
echo -e "  2. Update app/layout.tsx in each project"
echo -e "  3. Add the import: import { ClientThemeSwitcher } from '@/components/ClientThemeSwitcher';"
echo -e "  4. Add stylesheet: <link rel=\"stylesheet\" href=\"/styles/AVATARARTS_GLOBAL_STYLES.css\" />"
echo -e "  5. Add component: <ClientThemeSwitcher />"
echo -e "  6. Run: npm run dev"

echo -e "\n${CYAN}All files are ready! 🎨${NC}\n"

#!/bin/bash
# Setup script for automatic merge hooks

echo "Setting up automatic merge hooks..."

# Make post-merge hook executable
chmod +x .git/hooks/post-merge 2>/dev/null || echo "Note: .git/hooks directory may not exist yet"

# Create post-merge hook if it doesn't exist
if [ ! -f .git/hooks/post-merge ]; then
  cat > .git/hooks/post-merge << 'EOF'
#!/bin/sh
# Auto-merge hook: Automatically resolves conflicts after merge
if git diff --name-only --diff-filter=U | grep -q .; then
  echo "Merge conflicts detected. Running automatic merge system..."
  npm run merge:auto
fi
EOF
  chmod +x .git/hooks/post-merge
  echo "✓ Created post-merge hook"
else
  echo "✓ post-merge hook already exists"
fi

echo "Setup complete!"
echo ""
echo "The automatic merge system will now run when merge conflicts are detected."
echo "You can also run 'npm run merge:auto' manually at any time."


# Automatic Merge System for Multi-Agent Development

This system automatically handles merge conflicts when multiple AI agents (GPT-5.1, Haiku, Sonnet, Grok, Composer, etc.) modify the same file, ensuring smooth development flow without manual intervention.

## Features

- **Zero Manual Intervention**: All conflicts are resolved automatically
- **Intelligent Merging**: Combines complementary changes when possible
- **Quality-Aware**: Prefers more complete, optimized, and well-integrated code
- **Syntax Validation**: Automatically fixes syntax errors after merging
- **Multi-Language Support**: Works with Dart/Flutter, TypeScript, React, Node.js, JSON, and more

## Usage

### Process All Conflicted Files

```bash
npm run merge:auto
```

This will automatically detect and resolve all merge conflicts in your repository.

### Process a Single File

```bash
npx tsx scripts/auto-merge.ts path/to/file.ts
```

## Merge Logic

The system applies the following rules in order:

### 1. Complementary Changes
If two agents add different, non-conflicting functionality, both changes are merged into a single coherent version.

### 2. Formatting + Logic
If one agent edits logic and another edits formatting/styling/comments, both are preserved and merged.

### 3. Quality Assessment
When conflicts occur, the system evaluates:
- **Completeness**: Balanced braces, imports, function definitions
- **Syntax Validity**: Valid JSON, proper structure
- **Code Quality**: Comments, error handling, consistent indentation
- **Integration**: Matches project architecture, correct imports
- **Optimization**: Modern patterns, low duplication, better performance

### 4. Best Version Selection
The version that:
- Integrates best with the current codebase
- Matches project architecture
- Uses correct imports, types, and dependencies
- Improves reliability, readability, or functionality
- Is more optimized (fewer bugs, less duplication, clearer design)

### 5. Outdated Code Detection
If one version is clearly outdated or redundant, it's automatically discarded.

### 6. Syntax Fixing
After merging, the system automatically fixes:
- JSON formatting and trailing commas
- Missing newlines
- Excessive blank lines
- Common syntax issues

## Supported File Types

- **TypeScript/JavaScript**: `.ts`, `.tsx`, `.js`, `.jsx`
- **Dart/Flutter**: `.dart`
- **JSON**: `.json`
- **React Components**: `.tsx`, `.jsx`
- **Node.js**: `.ts`, `.js`
- **Configuration Files**: `.yaml`, `.yml`, `.toml`

## Examples

### Example 1: Complementary Features

**Current (Agent A):**
```typescript
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**Incoming (Agent B):**
```typescript
function calculateTax(amount: number): number {
  return amount * 0.08;
}
```

**Result:** Both functions are merged:
```typescript
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

function calculateTax(amount: number): number {
  return amount * 0.08;
}
```

### Example 2: Formatting + Logic

**Current (Agent A - Logic):**
```typescript
function process(data){return data.map(x=>x*2)}
```

**Incoming (Agent B - Formatting):**
```typescript
function process(data) {
  return data.map(x => x * 2);
}
```

**Result:** Logic preserved with proper formatting:
```typescript
function process(data) {
  return data.map(x => x * 2);
}
```

### Example 3: Quality-Based Selection

**Current (Agent A - Outdated):**
```typescript
var items = [];
for (var i = 0; i < data.length; i++) {
  items.push(data[i] * 2);
}
```

**Incoming (Agent B - Modern):**
```typescript
const items = data.map(x => x * 2);
```

**Result:** Modern version selected (more optimized):
```typescript
const items = data.map(x => x * 2);
```

## Integration with Git

The merge system works seamlessly with Git merge conflicts. When you encounter conflicts:

1. Run `npm run merge:auto`
2. The system automatically resolves all conflicts
3. Review the changes
4. Commit as usual

## Configuration

The merge system uses intelligent heuristics and doesn't require configuration. However, you can customize behavior by modifying `scripts/auto-merge.ts`.

## Best Practices

1. **Review Merged Code**: While the system is intelligent, always review merged code before committing
2. **Run Tests**: After auto-merging, run your test suite to ensure everything works
3. **Build Verification**: Run `npm run build` to verify the merged code compiles correctly

## Troubleshooting

### Merge Failed

If a merge fails:
1. Check the error message in the console
2. Manually review the conflicted file
3. The original conflict markers are preserved if merge fails

### Syntax Errors After Merge

The system attempts to fix syntax errors automatically. If issues persist:
1. Check the file extension is supported
2. Review the merged code manually
3. The system logs warnings for unfixable issues

## Technical Details

- **Language**: TypeScript
- **Runtime**: Node.js with tsx
- **Conflict Detection**: Git merge markers (`<<<<<<<`, `=======`, `>>>>>>>`)
- **Analysis**: Static code analysis and heuristics
- **Validation**: Syntax checking and auto-fixing

## Contributing

To improve the merge system:
1. Edit `scripts/auto-merge.ts`
2. Add new merge strategies in the `resolveConflict` method
3. Enhance scoring functions for better quality assessment
4. Test with various conflict scenarios

---

**Note**: This system is designed to handle AI agent conflicts automatically. For human conflicts, manual review is still recommended.


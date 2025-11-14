#!/usr/bin/env tsx
/**
 * Automatic Merge System for Multi-Agent File Modifications
 * 
 * Handles merge conflicts automatically when multiple AI agents (GPT-5.1, Haiku, Sonnet, Grok, Composer, etc.)
 * modify the same file. Applies intelligent merge logic to combine changes without blocking development flow.
 */

import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

interface ConflictBlock {
  startLine: number;
  endLine: number;
  currentContent: string;
  incomingContent: string;
  separatorLine: number;
  endMarkerLine: number;
}

interface MergeResult {
  merged: boolean;
  content: string;
  conflictsResolved: number;
  errors: string[];
}

class AutoMergeSystem {
  private conflictPattern = /^<<<<<<< (.+)$/;
  private separatorPattern = /^=======$/;
  private endPattern = /^>>>>>>> (.+)$/;

  /**
   * Main entry point: processes a file with merge conflicts
   */
  async mergeFile(filePath: string): Promise<MergeResult> {
    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      const lines = content.split('\n');
      
      const conflicts = this.detectConflicts(lines);
      
      if (conflicts.length === 0) {
        return {
          merged: false,
          content,
          conflictsResolved: 0,
          errors: ['No merge conflicts detected']
        };
      }

      console.log(`Found ${conflicts.length} conflict(s) in ${filePath}`);
      
      const mergedContent = this.resolveConflicts(lines, conflicts, filePath);
      const validatedContent = this.validateAndFix(mergedContent, filePath);
      
      // Write merged content
      fs.writeFileSync(filePath, validatedContent, 'utf-8');
      
      return {
        merged: true,
        content: validatedContent,
        conflictsResolved: conflicts.length,
        errors: []
      };
    } catch (error) {
      return {
        merged: false,
        content: '',
        conflictsResolved: 0,
        errors: [error instanceof Error ? error.message : String(error)]
      };
    }
  }

  /**
   * Detects all conflict blocks in a file
   */
  private detectConflicts(lines: string[]): ConflictBlock[] {
    const conflicts: ConflictBlock[] = [];
    let i = 0;

    while (i < lines.length) {
      const startMatch = lines[i].match(this.conflictPattern);
      if (startMatch) {
        const startLine = i;
        const currentMarker = startMatch[1];
        i++;

        // Find separator
        let separatorLine = -1;
        while (i < lines.length && !this.separatorPattern.test(lines[i])) {
          i++;
        }
        if (i < lines.length) {
          separatorLine = i;
          i++;
        }

        // Find end marker
        let endMarkerLine = -1;
        const currentContent: string[] = [];
        const incomingContent: string[] = [];

        while (i < lines.length) {
          if (this.endPattern.test(lines[i])) {
            endMarkerLine = i;
            i++;
            break;
          }
          incomingContent.push(lines[i]);
          i++;
        }

        // Extract current content (between start and separator)
        for (let j = startLine + 1; j < separatorLine; j++) {
          currentContent.push(lines[j]);
        }

        conflicts.push({
          startLine,
          endLine: endMarkerLine,
          currentContent: currentContent.join('\n'),
          incomingContent: incomingContent.join('\n'),
          separatorLine,
          endMarkerLine
        });
      } else {
        i++;
      }
    }

    return conflicts;
  }

  /**
   * Resolves all conflicts using intelligent merge logic
   */
  private resolveConflicts(
    lines: string[],
    conflicts: ConflictBlock[],
    filePath: string
  ): string {
    // Process conflicts in reverse order to maintain line numbers
    const result = [...lines];
    
    for (let i = conflicts.length - 1; i >= 0; i--) {
      const conflict = conflicts[i];
      const resolved = this.resolveConflict(conflict, filePath);
      
      // Replace conflict block with resolved content
      const resolvedLines = resolved.split('\n');
      result.splice(
        conflict.startLine,
        conflict.endMarkerLine - conflict.startLine + 1,
        ...resolvedLines
      );
    }

    return result.join('\n');
  }

  /**
   * Resolves a single conflict using intelligent merge logic
   */
  private resolveConflict(conflict: ConflictBlock, filePath: string): string {
    const current = conflict.currentContent.trim();
    const incoming = conflict.incomingContent.trim();
    const ext = path.extname(filePath).toLowerCase();

    // Rule 1: If one is empty, prefer the non-empty one
    if (!current && incoming) return incoming;
    if (current && !incoming) return current;
    if (!current && !incoming) return '';

    // Rule 2: If they're identical, return either
    if (current === incoming) return current;

    // Rule 3: Check if changes are complementary (can be merged)
    const merged = this.tryMergeComplementary(current, incoming, ext);
    if (merged) return merged;

    // Rule 4: Analyze which version is better
    const analysis = this.analyzeVersions(current, incoming, ext, filePath);
    
    // Rule 5: Prefer the version that integrates better with codebase
    if (analysis.betterVersion === 'current') {
      return current;
    } else if (analysis.betterVersion === 'incoming') {
      return incoming;
    }

    // Rule 6: If both are valid, prefer more complete/optimized
    if (analysis.currentScore > analysis.incomingScore) {
      return current;
    } else if (analysis.incomingScore > analysis.currentScore) {
      return incoming;
    }

    // Rule 7: Default to incoming (newer) if scores are equal
    return incoming;
  }

  /**
   * Attempts to merge complementary changes
   */
  private tryMergeComplementary(
    current: string,
    incoming: string,
    ext: string
  ): string | null {
    // For JSON files, try to merge objects
    if (ext === '.json') {
      try {
        const currentObj = JSON.parse(current);
        const incomingObj = JSON.parse(incoming);
        const merged = this.deepMergeObjects(currentObj, incomingObj);
        return JSON.stringify(merged, null, 2);
      } catch {
        // Not valid JSON or can't merge
      }
    }

    // Check if one is formatting/styling and other is logic
    const currentIsFormatting = this.isFormattingOnly(current);
    const incomingIsFormatting = this.isFormattingOnly(incoming);

    if (currentIsFormatting && !incomingIsFormatting) {
      // Current is formatting, incoming is logic - merge them
      return this.applyFormatting(incoming, current);
    }

    if (!currentIsFormatting && incomingIsFormatting) {
      // Incoming is formatting, current is logic - merge them
      return this.applyFormatting(current, incoming);
    }

    // Check if they add different functions/features
    if (this.areComplementaryFeatures(current, incoming, ext)) {
      return this.combineFeatures(current, incoming, ext);
    }

    return null;
  }

  /**
   * Analyzes which version is better
   */
  private analyzeVersions(
    current: string,
    incoming: string,
    ext: string,
    filePath: string
  ): {
    betterVersion: 'current' | 'incoming' | 'equal';
    currentScore: number;
    incomingScore: number;
  } {
    let currentScore = 0;
    let incomingScore = 0;

    // Score based on completeness
    currentScore += this.scoreCompleteness(current, ext);
    incomingScore += this.scoreCompleteness(incoming, ext);

    // Score based on syntax validity
    const currentValid = this.isValidSyntax(current, ext);
    const incomingValid = this.isValidSyntax(incoming, ext);
    
    if (currentValid && !incomingValid) currentScore += 10;
    if (!currentValid && incomingValid) incomingScore += 10;

    // Score based on code quality
    currentScore += this.scoreCodeQuality(current, ext);
    incomingScore += this.scoreCodeQuality(incoming, ext);

    // Score based on integration with codebase
    currentScore += this.scoreIntegration(current, filePath);
    incomingScore += this.scoreIntegration(incoming, filePath);

    // Score based on optimization
    currentScore += this.scoreOptimization(current, ext);
    incomingScore += this.scoreOptimization(incoming, ext);

    let betterVersion: 'current' | 'incoming' | 'equal' = 'equal';
    if (currentScore > incomingScore + 2) betterVersion = 'current';
    else if (incomingScore > currentScore + 2) betterVersion = 'incoming';

    return { betterVersion, currentScore, incomingScore };
  }

  /**
   * Scores code completeness
   */
  private scoreCompleteness(code: string, ext: string): number {
    let score = 0;

    // Check for balanced braces/brackets
    const braces = (code.match(/\{/g) || []).length - (code.match(/\}/g) || []).length;
    const brackets = (code.match(/\[/g) || []).length - (code.match(/\]/g) || []).length;
    const parens = (code.match(/\(/g) || []).length - (code.match(/\)/g) || []).length;

    if (Math.abs(braces) <= 1) score += 2;
    if (Math.abs(brackets) <= 1) score += 2;
    if (Math.abs(parens) <= 1) score += 2;

    // Check for imports (TypeScript/Dart)
    if (ext === '.ts' || ext === '.tsx' || ext === '.dart') {
      const imports = (code.match(/^import\s+/gm) || []).length;
      score += Math.min(imports, 5);
    }

    // Check for function/class definitions
    const functions = (code.match(/(function|const|let|var|class|interface|enum)\s+\w+/g) || []).length;
    score += Math.min(functions, 5);

    return score;
  }

  /**
   * Checks if code has valid syntax
   */
  private isValidSyntax(code: string, ext: string): boolean {
    try {
      if (ext === '.json') {
        JSON.parse(code);
        return true;
      }
      // For other languages, basic structural checks
      const openBraces = (code.match(/\{/g) || []).length;
      const closeBraces = (code.match(/\}/g) || []).length;
      return Math.abs(openBraces - closeBraces) <= 1;
    } catch {
      return false;
    }
  }

  /**
   * Scores code quality
   */
  private scoreCodeQuality(code: string, ext: string): number {
    let score = 0;

    // Prefer code with comments (but not too many)
    const commentRatio = (code.match(/\/\/|\/\*|\*/g) || []).length / Math.max(code.split('\n').length, 1);
    if (commentRatio > 0.05 && commentRatio < 0.3) score += 2;

    // Prefer code without obvious errors
    if (!code.includes('undefined') && !code.includes('null')) score += 1;
    if (!code.includes('TODO') && !code.includes('FIXME')) score += 1;

    // Prefer consistent indentation
    const lines = code.split('\n');
    const indentSizes = lines
      .filter(l => l.trim())
      .map(l => l.length - l.trimStart().length)
      .filter(i => i > 0);
    
    if (indentSizes.length > 0) {
      const avgIndent = indentSizes.reduce((a, b) => a + b, 0) / indentSizes.length;
      const variance = indentSizes.reduce((sum, i) => sum + Math.pow(i - avgIndent, 2), 0) / indentSizes.length;
      if (variance < 4) score += 2; // Consistent indentation
    }

    return score;
  }

  /**
   * Scores integration with codebase
   */
  private scoreIntegration(code: string, filePath: string): number {
    let score = 0;

    // Check if imports match project structure
    const imports = code.match(/^import\s+['"](.+?)['"]/gm) || [];
    for (const imp of imports) {
      const match = imp.match(/['"](.+?)['"]/);
      if (match) {
        const importPath = match[1];
        // Prefer relative imports or known package imports
        if (importPath.startsWith('.') || importPath.startsWith('@/')) score += 1;
        if (importPath.includes('react') || importPath.includes('express')) score += 1;
      }
    }

    // Check for project-specific patterns
    if (filePath.includes('src/server') && code.includes('express')) score += 2;
    if (filePath.includes('src/client') && code.includes('react')) score += 2;
    if (filePath.includes('lib/') && code.includes('package:')) score += 2;

    return score;
  }

  /**
   * Scores optimization level
   */
  private scoreOptimization(code: string, ext: string): number {
    let score = 0;

    // Prefer async/await over callbacks
    if (code.includes('async') && code.includes('await')) score += 2;

    // Prefer const/let over var
    const varCount = (code.match(/\bvar\s+/g) || []).length;
    const constLetCount = (code.match(/\b(const|let)\s+/g) || []).length;
    if (constLetCount > varCount) score += 2;

    // Prefer arrow functions
    if (code.includes('=>')) score += 1;

    // Avoid duplication
    const lines = code.split('\n');
    const uniqueLines = new Set(lines.map(l => l.trim()));
    const duplicationRatio = 1 - (uniqueLines.size / Math.max(lines.length, 1));
    if (duplicationRatio < 0.1) score += 2; // Low duplication

    return score;
  }

  /**
   * Checks if content is formatting-only
   */
  private isFormattingOnly(content: string): boolean {
    const trimmed = content.trim();
    if (!trimmed) return true;

    // Remove whitespace and check if meaningful content remains
    const noWhitespace = trimmed.replace(/\s+/g, '');
    const meaningfulChars = noWhitespace.replace(/[{}[\]();,]/g, '');
    
    return meaningfulChars.length < 10;
  }

  /**
   * Applies formatting from one version to another
   */
  private applyFormatting(logic: string, formatting: string): string {
    // Extract indentation style from formatting
    const formatLines = formatting.split('\n');
    const indentSize = formatLines.find(l => l.trim()) 
      ? formatLines.find(l => l.trim())!.length - formatLines.find(l => l.trim())!.trimStart().length
      : 2;

    // Apply consistent indentation to logic
    const logicLines = logic.split('\n');
    let indentLevel = 0;
    const formatted: string[] = [];

    for (const line of logicLines) {
      const trimmed = line.trim();
      if (!trimmed) {
        formatted.push('');
        continue;
      }

      // Decrease indent for closing braces
      if (trimmed.startsWith('}') || trimmed.startsWith(']') || trimmed.startsWith(')')) {
        indentLevel = Math.max(0, indentLevel - 1);
      }

      formatted.push(' '.repeat(indentLevel * indentSize) + trimmed);

      // Increase indent for opening braces
      if (trimmed.endsWith('{') || trimmed.endsWith('[') || trimmed.endsWith('(')) {
        indentLevel++;
      }
    }

    return formatted.join('\n');
  }

  /**
   * Checks if two code blocks are complementary features
   */
  private areComplementaryFeatures(
    current: string,
    incoming: string,
    ext: string
  ): boolean {
    // Extract function/class names
    const currentFeatures = this.extractFeatures(current, ext);
    const incomingFeatures = this.extractFeatures(incoming, ext);

    // Check if they define different features
    const overlap = currentFeatures.filter(f => incomingFeatures.includes(f));
    return overlap.length === 0 && currentFeatures.length > 0 && incomingFeatures.length > 0;
  }

  /**
   * Extracts feature names (functions, classes, etc.)
   */
  private extractFeatures(code: string, ext: string): string[] {
    const features: string[] = [];

    // Extract function names
    const functionMatches = code.match(/(?:function|const|let|var)\s+(\w+)\s*[=(]/g) || [];
    features.push(...functionMatches.map(m => {
      const match = m.match(/(\w+)\s*[=(]/);
      return match ? match[1] : '';
    }).filter(Boolean));

    // Extract class names
    const classMatches = code.match(/class\s+(\w+)/g) || [];
    features.push(...classMatches.map(m => {
      const match = m.match(/class\s+(\w+)/);
      return match ? match[1] : '';
    }).filter(Boolean));

    return features;
  }

  /**
   * Combines complementary features
   */
  private combineFeatures(current: string, incoming: string, ext: string): string {
    // Simple combination: append with proper spacing
    const combined = [current.trim(), incoming.trim()].join('\n\n');
    return combined;
  }

  /**
   * Deep merges two objects (for JSON)
   */
  private deepMergeObjects(target: any, source: any): any {
    const output = { ...target };

    for (const key in source) {
      if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
        output[key] = this.deepMergeObjects(target[key] || {}, source[key]);
      } else {
        output[key] = source[key];
      }
    }

    return output;
  }

  /**
   * Validates and fixes merged content
   */
  private validateAndFix(content: string, filePath: string): string {
    const ext = path.extname(filePath).toLowerCase();
    let fixed = content;

    // Fix JSON
    if (ext === '.json') {
      try {
        const parsed = JSON.parse(fixed);
        fixed = JSON.stringify(parsed, null, 2);
      } catch (error) {
        console.warn(`Warning: Could not parse JSON in ${filePath}, keeping original`);
      }
    }

    // Fix common syntax issues
    fixed = this.fixCommonIssues(fixed, ext);

    return fixed;
  }

  /**
   * Fixes common syntax issues
   */
  private fixCommonIssues(content: string, ext: string): string {
    let fixed = content;

    // Remove trailing commas in objects/arrays (for JSON)
    if (ext === '.json') {
      fixed = fixed.replace(/,(\s*[}\]])/g, '$1');
    }

    // Ensure file ends with newline
    if (!fixed.endsWith('\n')) {
      fixed += '\n';
    }

    // Remove duplicate blank lines (more than 2 consecutive)
    fixed = fixed.replace(/\n{3,}/g, '\n\n');

    return fixed;
  }

  /**
   * Processes all files with conflicts in the repository
   */
  async processRepository(): Promise<void> {
    try {
      // Get list of files with conflicts
      const gitStatus = execSync('git diff --name-only --diff-filter=U', { encoding: 'utf-8' });
      const conflictedFiles = gitStatus.trim().split('\n').filter(Boolean);

      if (conflictedFiles.length === 0) {
        console.log('No files with merge conflicts found.');
        return;
      }

      console.log(`Processing ${conflictedFiles.length} file(s) with conflicts...\n`);

      let totalResolved = 0;
      const errors: string[] = [];

      for (const file of conflictedFiles) {
        if (!fs.existsSync(file)) {
          console.warn(`Warning: File ${file} does not exist, skipping`);
          continue;
        }

        console.log(`Merging ${file}...`);
        const result = await this.mergeFile(file);

        if (result.merged) {
          console.log(`✓ Resolved ${result.conflictsResolved} conflict(s) in ${file}`);
          totalResolved += result.conflictsResolved;
        } else {
          console.error(`✗ Failed to merge ${file}: ${result.errors.join(', ')}`);
          errors.push(...result.errors.map(e => `${file}: ${e}`));
        }
      }

      console.log(`\n✓ Successfully resolved ${totalResolved} conflict(s) in ${conflictedFiles.length} file(s)`);
      
      if (errors.length > 0) {
        console.error(`\n✗ ${errors.length} error(s) occurred:`);
        errors.forEach(e => console.error(`  - ${e}`));
        process.exit(1);
      }
    } catch (error) {
      console.error('Error processing repository:', error);
      process.exit(1);
    }
  }
}

// Main execution
if (require.main === module) {
  const merger = new AutoMergeSystem();
  const filePath = process.argv[2];

  if (filePath) {
    // Process single file
    merger.mergeFile(filePath).then(result => {
      if (result.merged) {
        console.log(`✓ Successfully merged ${filePath}`);
        process.exit(0);
      } else {
        console.error(`✗ Failed to merge ${filePath}: ${result.errors.join(', ')}`);
        process.exit(1);
      }
    });
  } else {
    // Process entire repository
    merger.processRepository();
  }
}

export { AutoMergeSystem };


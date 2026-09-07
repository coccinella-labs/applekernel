// SPDX-License-Identifier: MIT
// Copyright (c) 2025 KERNEL.METAL (coccinella-labs)

/**
 * check-spdx.js
 * Node script used by the workflow to check changed files for SPDX headers.
 * It reads project.meta.json for expected values and prints a JSON report
 * to stdout that the workflow can consume.
 */

const fs = require('fs');
const { execSync } = require('child_process');

function readMeta() {
  const raw = fs.readFileSync('project.meta.json', 'utf8');
  return JSON.parse(raw);
}

function gitChangedFiles() {
  // uses the merge-base between the PR head and base to find changed files
  try {
    const base = process.env.GITHUB_BASE_REF || execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
    const prRange = process.env.GITHUB_SHA ? `${process.env.GITHUB_SHA}^...${process.env.GITHUB_SHA}` : null;
    // fallback to diff against origin/main
    const diff = execSync('git diff --name-only origin/main...HEAD || true').toString().trim();
    if (!diff) return [];
    return diff.split('\n').filter(Boolean);
  } catch (e) {
    // fallback: all files
    const all = execSync('git ls-files').toString().trim();
    return all.split('\n');
  }
}

function checkFileHeader(file, expectedSpdx, expectedCopyright) {
  try {
    const content = fs.readFileSync(file, 'utf8');
    const hasSpdx = content.includes(expectedSpdx);
    const hasCopyright = content.includes(expectedCopyright.split('\n')[0]);
    return { file, hasSpdx, hasCopyright };
  } catch (e) {
    return { file, error: 'read-error' };
  }
}

function main() {
  const meta = readMeta();
  const changed = gitChangedFiles();
  const fileTypesRegex = /\.ts$|\.tsx$|\.js$|\.jsx$|\.py$|\.c$|\.cpp$|\.h$|\.go$|\.rs$|\.java$|\.rb$|\.sh$/i;
  const relevant = changed.filter(f => fileTypesRegex.test(f));

  const results = relevant.map(f => checkFileHeader(f, meta.spdx, meta.copyright));

  const missing = results.filter(r => !r.hasSpdx || !r.hasCopyright);

  const report = { totalChecked: results.length, missing, results };

  console.log(JSON.stringify(report));

  if (missing.length > 0) process.exit(2);
  process.exit(0);
}

main();
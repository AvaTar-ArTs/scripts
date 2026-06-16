#!/usr/bin/env python3
"""
GitHub Repository Bulk Rename Script
Renames multiple repositories using the GitHub API.

Usage:
    python3 rename-repos.py --token YOUR_TOKEN

Requirements:
    - GitHub Personal Access Token with repo admin permissions
    - Python 3.6+
    - requests library (install with: pip install requests)
"""

import requests
import argparse
import sys
from typing import Dict, List, Tuple

# Mapping of old repo names to new names
RENAME_MAPPING: Dict[str, str] = {
    "Ai-Code-Hub": "AgentForge-Core",
    "Ai-Merge-GitHub": "GitMergeAI",
    "VAULT-OPS-PRO": "CreatorOS-Vault",
    "trend-pulse-pro": "CreatorOS-Trends",
    "n8n_workflows": "CreatorOS-Workflows",
    "PasTe-Export": "CreatorOS-Export",
    "NotebookLM": "NotebookLM-Lab",
    "my-manus": "AgentForge-Manus",
    "my-cline": "AgentForge-Cline",
    "my-codex": "AgentForge-Codex",
}

class GitHubRepoRenamer:
    def __init__(self, token: str, owner: str = "AvaTar-ArTs"):
        self.token = token
        self.owner = owner
        self.base_url = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
        }

    def rename_repo(self, old_name: str, new_name: str) -> Tuple[bool, str]:
        """
        Rename a single repository.
        
        Args:
            old_name: Current repository name
            new_name: New repository name
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        url = f"{self.base_url}/repos/{self.owner}/{old_name}"
        payload = {"name": new_name}
        
        try:
            response = requests.patch(url, json=payload, headers=self.headers, timeout=10)
            
            if response.status_code == 200:
                return True, f"✓ {old_name} → {new_name}"
            elif response.status_code == 404:
                return False, f"✗ {old_name}: Repository not found (404)"
            elif response.status_code == 422:
                error_msg = response.json().get("message", "Validation failed")
                return False, f"✗ {old_name}: {error_msg}"
            else:
                return False, f"✗ {old_name}: HTTP {response.status_code} - {response.text}"
                
        except requests.exceptions.Timeout:
            return False, f"✗ {old_name}: Request timeout"
        except requests.exceptions.RequestException as e:
            return False, f"✗ {old_name}: {str(e)}"

    def rename_all(self) -> None:
        """Rename all repositories in the mapping."""
        print(f"\n🔄 Starting bulk rename for {len(RENAME_MAPPING)} repositories...\n")
        
        success_count = 0
        failure_count = 0
        
        for old_name, new_name in RENAME_MAPPING.items():
            success, message = self.rename_repo(old_name, new_name)
            print(message)
            
            if success:
                success_count += 1
            else:
                failure_count += 1
        
        print(f"\n{'='*60}")
        print(f"✓ Successful: {success_count}/{len(RENAME_MAPPING)}")
        print(f"✗ Failed: {failure_count}/{len(RENAME_MAPPING)}")
        print(f"{'='*60}\n")
        
        return failure_count == 0

def main():
    parser = argparse.ArgumentParser(
        description="Bulk rename GitHub repositories",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 rename-repos.py --token ghp_xxxxxxxxxxxxxxxxxxxx
  python3 rename-repos.py --token $GITHUB_TOKEN
        """
    )
    
    parser.add_argument(
        "--token",
        required=True,
        help="GitHub Personal Access Token (required)"
    )
    
    parser.add_argument(
        "--owner",
        default="AvaTar-ArTs",
        help="GitHub username/org (default: AvaTar-ArTs)"
    )
    
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be renamed without actually doing it"
    )
    
    args = parser.parse_args()
    
    if args.dry_run:
        print("\n📋 DRY RUN - No changes will be made\n")
        print(f"{'Old Name':<30} → {'New Name':<30}")
        print("-" * 62)
        for old_name, new_name in RENAME_MAPPING.items():
            print(f"{old_name:<30} → {new_name:<30}")
        print()
        return
    
    renamer = GitHubRepoRenamer(args.token, args.owner)
    success = renamer.rename_all()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

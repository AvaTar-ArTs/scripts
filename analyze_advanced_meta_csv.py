#!/usr/bin/env python3
"""
Analyzer for the advanced scripts meta CSV
This script analyzes the generated CSV and provides statistics and insights
"""

import pandas as pd
from pathlib import Path

def analyze_csv():
    """Analyze the generated CSV file and provide statistics"""
    csv_path = Path.home() / 'scripts' / 'advanced_scripts_meta.csv'
    
    if not csv_path.exists():
        print(f"CSV file not found: {csv_path}")
        return
    
    # Read the CSV
    df = pd.read_csv(csv_path)
    
    print("## Advanced Scripts Meta Analysis Report")
    print(f"### Dataset Overview")
    print(f"- Total scripts analyzed: {len(df)}")
    print(f"- Total columns: {len(df.columns)}")
    print(f"- Date range: {df['modification_time'].min()} to {df['modification_time'].max()}")
    
    print(f"\n### Language Distribution:")
    language_counts = df['language'].value_counts()
    for lang, count in language_counts.items():
        print(f"- {lang}: {count} ({count/len(df)*100:.1f}%)")
    
    print(f"\n### Category Distribution:")
    category_counts = df['category'].value_counts()
    for category, count in category_counts.items():
        print(f"- {category}: {count} ({count/len(df)*100:.1f}%)")
    
    print(f"\n### Complexity Distribution:")
    complexity_counts = df['complexity'].value_counts()
    for complexity, count in complexity_counts.items():
        print(f"- {complexity}: {count} ({count/len(df)*100:.1f}%)")
    
    print(f"\n### File Size Statistics:")
    print(f"- Average file size: {df['size_bytes'].mean():.0f} bytes ({df['size_bytes'].mean()/1024:.1f} KB)")
    print(f"- Median file size: {df['size_bytes'].median():.0f} bytes ({df['size_bytes'].median()/1024:.1f} KB)")
    print(f"- Largest file: {df['size_bytes'].max():.0f} bytes ({df['size_bytes'].max()/1024:.1f} KB)")
    print(f"- Smallest file: {df['size_bytes'].min():.0f} bytes")
    
    print(f"\n### Lines of Code Statistics:")
    print(f"- Average lines: {df['num_lines'].mean():.0f}")
    print(f"- Median lines: {df['num_lines'].median():.0f}")
    print(f"- Maximum lines: {df['num_lines'].max():.0f}")
    print(f"- Minimum lines: {df['num_lines'].min():.0f}")
    
    # Count scripts with API keys
    api_scripts = df[df['apis_used'].notna() & (df['apis_used'] != '')]
    print(f"\n### API Usage:")
    print(f"- Scripts using APIs: {len(api_scripts)} ({len(api_scripts)/len(df)*100:.1f}%)")
    
    # Print some examples of scripts with APIs
    if len(api_scripts) > 0:
        print(f"- Example scripts with APIs:")
        for _, row in api_scripts.head(5).iterrows():
            print(f"  * {row['filename']}: {row['apis_used']}")
    
    # Save summary statistics to a file
    summary_path = Path.home() / 'scripts' / 'advanced_scripts_meta_summary.txt'
    with open(summary_path, 'w') as f:
        f.write("Advanced Scripts Meta Analysis Summary\n")
        f.write("="*40 + "\n\n")
        f.write(f"Total scripts analyzed: {len(df)}\n")
        f.write(f"Language distribution:\n")
        for lang, count in language_counts.items():
            f.write(f"  {lang}: {count} ({count/len(df)*100:.1f}%)\n")
        f.write(f"\nCategory distribution:\n")
        for category, count in category_counts.items():
            f.write(f"  {category}: {count} ({count/len(df)*100:.1f}%)\n")
        f.write(f"\nComplexity distribution:\n")
        for complexity, count in complexity_counts.items():
            f.write(f"  {complexity}: {count} ({count/len(df)*100:.1f}%)\n")
        f.write(f"\nFile size statistics:\n")
        f.write(f"  Average: {df['size_bytes'].mean():.0f} bytes\n")
        f.write(f"  Median: {df['size_bytes'].median():.0f} bytes\n")
        f.write(f"  Max: {df['size_bytes'].max():.0f} bytes\n")
        f.write(f"  Min: {df['size_bytes'].min():.0f} bytes\n")
        f.write(f"\nLines of code statistics:\n")
        f.write(f"  Average: {df['num_lines'].mean():.0f}\n")
        f.write(f"  Median: {df['num_lines'].median():.0f}\n")
        f.write(f"  Max: {df['num_lines'].max():.0f}\n")
        f.write(f"  Min: {df['num_lines'].min():.0f}\n")
        f.write(f"\nAPI usage:\n")
        f.write(f"  Scripts using APIs: {len(api_scripts)} ({len(api_scripts)/len(df)*100:.1f}%)\n")
    
    print(f"\n### Summary saved to: {summary_path}")

if __name__ == "__main__":
    analyze_csv()
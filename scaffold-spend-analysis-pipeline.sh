#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# ========= CONFIG ==========
BASE="$HOME/Documents/GitHub/spend-analysis-pipeline"
mkdir -p "$BASE/data" "$BASE/output" "$BASE/cache" "$BASE/notebooks"

PY="$BASE/spend_analysis.py"
REQ="$BASE/requirements.txt"
CSV="$BASE/data/AccountHistory.csv"
NOTE="$BASE/notebooks/spend_analysis_starter.ipynb"

# ========= PYTHON SCRIPT ==========
cat > "$PY" << 'EOF'
import pandas as pd
import numpy as np
import re
import openai
import os
from tqdm import tqdm
import matplotlib.pyplot as plt

CSV_PATH = "data/AccountHistory.csv"
ENHANCED_PATH = "output/AccountHistory_enhanced.csv"
VENDOR_CACHE = "cache/vendor_lookup.csv"
CATEGORY_CACHE = "cache/category_lookup.csv"

def get_openai_key():
    key = os.environ.get("OPENAI_API_KEY")
    if not key and os.path.exists(os.path.expanduser("~/.env")):
        with open(os.path.expanduser("~/.env")) as f:
            for line in f:
                if line.startswith("OPENAI_API_KEY="):
                    key = line.split("=",1)[1].strip()
                    break
    if not key:
        raise RuntimeError("OpenAI API key not found!")
    return key

openai.api_key = get_openai_key()

def load_and_validate(csv_path):
    df = pd.read_csv(csv_path)
    if 'Post Date' in df.columns:
        df['Post Date'] = pd.to_datetime(df['Post Date'])
    else:
        raise ValueError("Expected column 'Post Date' not found.")
    df.columns = [c.strip() for c in df.columns]
    print(f"\nLoaded {len(df)} rows from {csv_path}")
    print("Columns:", ", ".join(df.columns))
    print(df.head(3))
    return df

df = load_and_validate(CSV_PATH)

def clean_description(desc):
    desc = desc.lower()
    desc = re.sub(r'[-/#:;,_\.0-9]+', ' ', desc)
    desc = re.sub(r'\s+', ' ', desc).strip()
    return desc

df['Description_clean'] = df['Description'].apply(clean_description)

def gpt_normalize_vendor(desc):
    prompt = (
        f"Normalize this bank transaction to a clean, human-friendly vendor name. "
        f"Ignore numbers, suffixes, or irrelevant words. "
        f"Example: 'withdrawal debit card mc debit seminol apple com bill cadate card' → 'Apple'.\n"
        f"Description: '{desc}'\nVendor:"
    )
    try:
        resp = openai.ChatCompletion.create(
            model="gpt-4o",
            messages=[{"role":"system","content":prompt}],
            max_tokens=12,
            temperature=0)
        return resp['choices'][0]['message']['content'].strip()
    except Exception as e:
        print("GPT error:", e)
        return "Unknown"

if os.path.exists(VENDOR_CACHE):
    vendor_lookup = pd.read_csv(VENDOR_CACHE, index_col=0).to_dict()['Vendor']
else:
    unique_desc = df['Description_clean'].drop_duplicates().tolist()
    vendor_lookup = {}
    for desc in tqdm(unique_desc, desc="Normalizing vendors (GPT-4o)"):
        vendor_lookup[desc] = gpt_normalize_vendor(desc)
    pd.DataFrame.from_dict(vendor_lookup, orient='index', columns=['Vendor']).to_csv(VENDOR_CACHE)
df['Vendor'] = df['Description_clean'].map(vendor_lookup)

CATEGORY_RULES = [
    (r'(instacart|publix|grocery|trader joe)', 'Groceries'),
    (r'(apple|google|openai|notion|adobe|canva|leonardo|invideo|superpower|paddle)', 'SaaS'),
    (r'(sunoco|wawa|shell|gasoline|bp|circle k)', 'Gas'),
    (r'(chipotle|mcdonald|restaurant|food|cafe|starbucks)', 'Food'),
    (r'(venmo|transfer|payout|deposit)', 'Transfer'),
    (r'(netflix|prime|youtube|subscription)', 'Subscription'),
    (r'(fee|charge|overdraft|interest)', 'Fees'),
    (r'(rent|realty|appfolio|watson)', 'Rent'),
]

def rule_category(desc):
    for pattern, cat in CATEGORY_RULES:
        if re.search(pattern, desc):
            return cat
    return None

df['Rule_Category'] = df['Description_clean'].apply(rule_category)

def gpt_category(desc):
    prompt = (
        "Classify this transaction into ONE category: "
        "Groceries, Gas, Food, Utilities, SaaS, Subscription, Transfer, Fees, Rent, Income, Shopping, Miscellaneous.\n"
        f"Description: '{desc}'\nCategory:"
    )
    try:
        resp = openai.ChatCompletion.create(
            model="gpt-4o",
            messages=[{"role":"system","content":prompt}],
            max_tokens=8,
            temperature=0)
        return resp['choices'][0]['message']['content'].strip()
    except Exception as e:
        print("GPT error:", e)
        return "Unknown"

if os.path.exists(CATEGORY_CACHE):
    category_lookup = pd.read_csv(CATEGORY_CACHE, index_col=0).to_dict()['Category']
else:
    cat_needed = df[df['Rule_Category'].isna()]['Description_clean'].drop_duplicates().tolist()
    category_lookup = {}
    for desc in tqdm(cat_needed, desc="Categorizing (GPT-4o)"):
        category_lookup[desc] = gpt_category(desc)
    pd.DataFrame.from_dict(category_lookup, orient='index', columns=['Category']).to_csv(CATEGORY_CACHE)
df['Category'] = df.apply(lambda row: row['Rule_Category'] or category_lookup.get(row['Description_clean'], "Unknown"), axis=1)

print("\nRecurring Vendors (possible subscriptions):")
recurring = df['Vendor'].value_counts()[df['Vendor'].value_counts()>6]
print(recurring)
recurring_stats = df[df['Vendor'].isin(recurring.index)].groupby('Vendor')['Debit'].agg(['count','mean','sum'])
print("\nStats for recurring vendors:")
print(recurring_stats)

def is_income(row):
    d = row['Description_clean']
    if re.search(r'(deposit|payout|transfer|income|refund|rebate)', d):
        return True
    return False

df['Amount'] = df.apply(lambda row: abs(row['Debit']) if not is_income(row) else -abs(row['Debit']), axis=1)
df['Month'] = df['Post Date'].dt.to_period('M')
monthly_cashflow = df.groupby('Month')['Amount'].sum()
print("\nMonthly net outflow (negative = net spent):")
print(monthly_cashflow.tail(12))

df = df.sort_values('Post Date')
df['Overdraft'] = df['Balance'] < 0
print(f"\nOverdraft events: {df['Overdraft'].sum()}")
print(f"Lowest balance: ${df['Balance'].min():.2f} on {df.loc[df['Balance'].idxmin(), 'Post Date'].date()}")

debit_threshold = df['Debit'].quantile(0.99)
df['Anomaly_High'] = df['Debit'] > debit_threshold
recent_month = df['Post Date'].dt.to_period('M').max()
last_month_vendors = set(df[df['Post Date'].dt.to_period('M') == recent_month]['Vendor'])
known_vendors = set(df[df['Post Date'].dt.to_period('M') < recent_month]['Vendor'])
df['Anomaly_NewVendor'] = df['Vendor'].apply(lambda x: x in last_month_vendors and x not in known_vendors)

print("\nTransactions flagged as high outlier:")
print(df[df['Anomaly_High']][['Post Date', 'Vendor', 'Debit', 'Description']].tail(5))

plt.figure(figsize=(12,5))
monthly_cashflow.plot(kind='bar', title='Monthly Net Outflow')
plt.ylabel('Amount ($)')
plt.tight_layout()
plt.show()

df.groupby('Category')['Debit'].sum().sort_values(ascending=False).plot(
    kind='bar', title="Spending by Category", figsize=(8,4))
plt.ylabel("Total Spent")
plt.tight_layout()
plt.show()

df.to_csv(ENHANCED_PATH, index=False)
print(f"\nEnhanced data saved to {ENHANCED_PATH}")

def gpt_summary(monthly, cats, recurring):
    month_str = ', '.join([f"{str(k)}: ${v:.0f}" for k,v in monthly[-6:].items()])
    cats_str = ', '.join([f"{k}: ${v:.0f}" for k,v in cats.head(5).items()])
    rec_str = ', '.join(recurring.index[:5])
    prompt = (
        "Write a 3-sentence summary of this user's spending.\n"
        f"Recent months: {month_str}\n"
        f"Top categories: {cats_str}\n"
        f"Recurring: {rec_str}\nSummary:"
    )
    resp = openai.ChatCompletion.create(
        model="gpt-4o",
        messages=[{"role":"system","content":prompt}],
        max_tokens=100,
        temperature=0.5)
    return resp['choices'][0]['message']['content'].strip()

try:
    cats = df.groupby('Category')['Debit'].sum().sort_values(ascending=False)
    summary = gpt_summary(monthly_cashflow, cats, recurring)
    print("\nGPT-4o Narrative Summary:")
    print(summary)
except Exception as e:
    print("Narrative summary failed:", e)
EOF

# ========= REQUIREMENTS ==========
cat > "$REQ" << EOF
pandas
numpy
tqdm
matplotlib
openai
EOF

# ========= SAMPLE CSV ==========
if [ ! -f "$CSV" ]; then
  echo "Post Date,Description,Debit,Status,Balance" > "$CSV"
fi

# ========= JUPYTER STUB (optional) =========
cat > "$NOTE" << EOF
{
 "cells": [],
 "metadata": {},
 "nbformat": 4,
 "nbformat_minor": 2
}
EOF

# ========= DONE ==========
echo "Spend analysis pipeline created at $BASE"
echo "Start with: cd $BASE && pip install -r requirements.txt"
echo "Put your CSV in data/ and run: python spend_analysis.py"

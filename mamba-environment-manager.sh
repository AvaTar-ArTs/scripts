#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Interactive environment management

while true; do
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║         🐍 MAMBA ENVIRONMENT MANAGER 🐍                         ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📦 CURRENT STATUS"
    echo "═══════════════════════════════════════════════════════════════════"

    # Show active environment
    if [ -n "$CONDA_DEFAULT_ENV" ]; then
        echo "✅ Active environment: $CONDA_DEFAULT_ENV"
    else
        echo "⚪ No environment active"
    fi

    echo ""
    echo "📋 Available environments:"
    mamba env list | grep -E "(automation-master|ai-voice-agents|data-analysis|content-generation|web-scraping)" | awk '{print "   " $1}' || echo "   (none found)"

    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "OPTIONS:"
    echo "═══════════════════════════════════════════════════════════════════"
    echo "  1) List all environments (detailed)"
    echo "  2) Create new environment"
    echo "  3) Activate environment"
    echo "  4) Update environment"
    echo "  5) Remove environment"
    echo "  6) Export environment to file"
    echo "  7) Test all environments"
    echo "  8) Install package in current environment"
    echo "  9) Show environment info"
    echo ""
    echo "  0) Exit"
    echo ""
    read -p "Enter choice [0-9]: " choice

    case $choice in
        1)
            echo ""
            echo "📋 All Mamba Environments:"
            echo "═══════════════════════════════════════════════════════════════════"
            mamba env list
            echo ""
            read -p "Press Enter to continue..."
            ;;

        2)
            echo ""
            echo "📦 Create New Environment"
            echo "═══════════════════════════════════════════════════════════════════"
            echo "Available templates:"
            ls ~/ai-sites/environments/*.yml | xargs -n1 basename | sed 's/.yml$//' | awk '{print "  - " $0}'
            echo ""
            read -p "Enter environment name (or template name): " env_name

            env_file="$HOME/ai-sites/environments/$env_name.yml"
            if [ -f "$env_file" ]; then
                echo "✅ Found template: $env_file"
                mamba env create -f "$env_file"
            else
                echo "❌ Template not found. Creating basic environment..."
                mamba create -n "$env_name" python=3.11 pip -y
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        3)
            echo ""
            echo "🔄 Activate Environment"
            echo "═══════════════════════════════════════════════════════════════════"
            mamba env list | grep -E "(automation-master|ai-voice-agents|data-analysis|content-generation|web-scraping)" | awk '{print "  " $1}'
            echo ""
            read -p "Enter environment name: " env_name

            if mamba env list | grep -q "^$env_name "; then
                echo "✅ To activate, run:"
                echo "   mamba activate $env_name"
                echo ""
                echo "Or in a new shell session:"
                echo "   eval \"\$(mamba shell hook -s zsh)\" && mamba activate $env_name"
            else
                echo "❌ Environment '$env_name' not found"
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        4)
            echo ""
            echo "🔄 Update Environment"
            echo "═══════════════════════════════════════════════════════════════════"

            if [ -z "$CONDA_DEFAULT_ENV" ]; then
                echo "❌ No environment active. Activate one first:"
                echo "   mamba activate <env-name>"
            else
                echo "Current environment: $CONDA_DEFAULT_ENV"
                echo ""
                read -p "Update all packages? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    mamba update --all -y
                    echo "✅ Environment updated"
                fi
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        5)
            echo ""
            echo "🗑️  Remove Environment"
            echo "═══════════════════════════════════════════════════════════════════"
            mamba env list | awk 'NR>2 {print "  " $1}'
            echo ""
            read -p "Enter environment name to remove: " env_name

            if [ -z "$env_name" ]; then
                echo "❌ No environment specified"
            elif [ "$env_name" = "base" ]; then
                echo "❌ Cannot remove base environment"
            else
                read -p "⚠️  Really remove '$env_name'? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    mamba env remove -n "$env_name" -y
                    echo "✅ Environment removed"
                fi
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        6)
            echo ""
            echo "💾 Export Environment"
            echo "═══════════════════════════════════════════════════════════════════"

            if [ -z "$CONDA_DEFAULT_ENV" ]; then
                echo "❌ No environment active. Activate one first."
            else
                output_file="$HOME/ai-sites/environments/$CONDA_DEFAULT_ENV-$(date +%Y%m%d).yml"
                echo "Exporting $CONDA_DEFAULT_ENV to:"
                echo "  $output_file"
                echo ""
                mamba env export > "$output_file"
                echo "✅ Environment exported"
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        7)
            echo ""
            echo "🧪 Test All Environments"
            echo "═══════════════════════════════════════════════════════════════════"

            for env in automation-master ai-voice-agents data-analysis content-generation web-scraping; do
                if mamba env list | grep -q "^$env "; then
                    echo "Testing $env..."
                    if eval "$(mamba shell hook -s zsh)" && mamba activate "$env" && python --version >/dev/null 2>&1; then
                        echo "  ✅ $env OK"
                    else
                        echo "  ❌ $env FAILED"
                    fi
                    mamba deactivate 2>/dev/null || true
                else
                    echo "  ⚪ $env not installed"
                fi
            done

            echo ""
            read -p "Press Enter to continue..."
            ;;

        8)
            echo ""
            echo "📦 Install Package"
            echo "═══════════════════════════════════════════════════════════════════"

            if [ -z "$CONDA_DEFAULT_ENV" ]; then
                echo "❌ No environment active. Activate one first."
            else
                echo "Current environment: $CONDA_DEFAULT_ENV"
                echo ""
                read -p "Enter package name: " package_name

                if [ -n "$package_name" ]; then
                    echo ""
                    echo "Install via:"
                    echo "  1) mamba (preferred)"
                    echo "  2) pip"
                    read -p "Choice [1-2]: " install_method

                    if [ "$install_method" = "1" ]; then
                        mamba install "$package_name" -y
                    else
                        pip install "$package_name"
                    fi
                    echo "✅ Package installed"
                fi
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        9)
            echo ""
            echo "ℹ️  Environment Info"
            echo "═══════════════════════════════════════════════════════════════════"

            if [ -z "$CONDA_DEFAULT_ENV" ]; then
                echo "❌ No environment active"
            else
                echo "Environment: $CONDA_DEFAULT_ENV"
                echo "Python: $(python --version 2>&1)"
                echo "Location: $(which python)"
                echo ""
                echo "Installed packages:"
                mamba list | head -20
                echo "  ... (showing first 20)"
            fi

            echo ""
            read -p "Press Enter to continue..."
            ;;

        0)
            echo ""
            echo "👋 Goodbye!"
            exit 0
            ;;

        *)
            echo ""
            echo "❌ Invalid choice"
            sleep 1
            ;;
    esac
done

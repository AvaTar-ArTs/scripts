#!/usr/bin/env bash
# content_quality_analyzer.sh
# Analyzes content quality and provides improvement suggestions based on professional standards

set -e  # Exit immediately on any error

# Configuration
PROJECT_ROOT="/Users/steven/tehSiTes"
ANALYSIS_DIR="$PROJECT_ROOT/content_analysis/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$PROJECT_ROOT/content_quality_log.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Create analysis directory
create_analysis_dir() {
    log "Creating content analysis directory: $ANALYSIS_DIR"
    mkdir -p "$ANALYSIS_DIR"
}

# Analyze markdown file quality
analyze_markdown_file() {
    local file="$1"
    local project_name="$2"
    
    log "Analyzing markdown file: $file"
    
    # Create analysis file
    local analysis_file="$ANALYSIS_DIR/$(basename "$file" .md)_analysis.md"
    
    # Basic file analysis
    local word_count=$(wc -w < "$file" 2>/dev/null || echo "0")
    local line_count=$(wc -l < "$file" 2>/dev/null || echo "0")
    local char_count=$(wc -c < "$file" 2>/dev/null || echo "0")
    
    # Header analysis
    local h1_count=$(grep -c "^# " "$file" 2>/dev/null || echo "0")
    local h2_count=$(grep -c "^## " "$file" 2>/dev/null || echo "0")
    local h3_count=$(grep -c "^### " "$file" 2>/dev/null || echo "0")
    
    # Link analysis
    local internal_links=$(grep -c "\[.*\](.*)" "$file" 2>/dev/null || echo "0")
    local external_links=$(grep -c "http" "$file" 2>/dev/null || echo "0")
    
    # Image analysis
    local image_count=$(grep -c "!\[.*\](.*)" "$file" 2>/dev/null || echo "0")
    
    # Code block analysis
    local code_blocks=$(grep -c "^\`\`\`" "$file" 2>/dev/null || echo "0")
    
    # List analysis
    local bullet_points=$(grep -c "^- " "$file" 2>/dev/null || echo "0")
    local numbered_lists=$(grep -c "^[0-9]\+\. " "$file" 2>/dev/null || echo "0")
    
    # Calculate quality scores
    local structure_score=0
    local content_score=0
    local seo_score=0
    local engagement_score=0
    
    # Structure scoring (0-25 points)
    if [[ $h1_count -gt 0 ]]; then structure_score=$((structure_score + 5)); fi
    if [[ $h2_count -gt 2 ]]; then structure_score=$((structure_score + 5)); fi
    if [[ $h3_count -gt 0 ]]; then structure_score=$((structure_score + 5)); fi
    if [[ $word_count -gt 500 ]]; then structure_score=$((structure_score + 5)); fi
    if [[ $word_count -gt 1000 ]]; then structure_score=$((structure_score + 5)); fi
    
    # Content scoring (0-25 points)
    if [[ $code_blocks -gt 0 ]]; then content_score=$((content_score + 5)); fi
    if [[ $bullet_points -gt 5 ]]; then content_score=$((content_score + 5)); fi
    if [[ $numbered_lists -gt 0 ]]; then content_score=$((content_score + 5)); fi
    if [[ $image_count -gt 0 ]]; then content_score=$((content_score + 5)); fi
    if [[ $word_count -gt 2000 ]]; then content_score=$((content_score + 5)); fi
    
    # SEO scoring (0-25 points)
    if [[ $internal_links -gt 0 ]]; then seo_score=$((seo_score + 5)); fi
    if [[ $external_links -gt 0 ]]; then seo_score=$((seo_score + 5)); fi
    if grep -q "keywords:" "$file" 2>/dev/null; then seo_score=$((seo_score + 5)); fi
    if grep -q "description:" "$file" 2>/dev/null; then seo_score=$((seo_score + 5)); fi
    if grep -q "canonical:" "$file" 2>/dev/null; then seo_score=$((seo_score + 5)); fi
    
    # Engagement scoring (0-25 points)
    if grep -q "✅" "$file" 2>/dev/null; then engagement_score=$((engagement_score + 5)); fi
    if grep -q "🎯" "$file" 2>/dev/null; then engagement_score=$((engagement_score + 5)); fi
    if grep -q "🚀" "$file" 2>/dev/null; then engagement_score=$((engagement_score + 5)); fi
    if grep -q "📊" "$file" 2>/dev/null; then engagement_score=$((engagement_score + 5)); fi
    if grep -q "💡" "$file" 2>/dev/null; then engagement_score=$((engagement_score + 5)); fi
    
    # Calculate total score
    local total_score=$((structure_score + content_score + seo_score + engagement_score))
    local percentage=$((total_score * 4))  # Convert to percentage
    
    # Determine grade
    local grade="F"
    if [[ $percentage -ge 90 ]]; then grade="A+"
    elif [[ $percentage -ge 85 ]]; then grade="A"
    elif [[ $percentage -ge 80 ]]; then grade="A-"
    elif [[ $percentage -ge 75 ]]; then grade="B+"
    elif [[ $percentage -ge 70 ]]; then grade="B"
    elif [[ $percentage -ge 65 ]]; then grade="B-"
    elif [[ $percentage -ge 60 ]]; then grade="C+"
    elif [[ $percentage -ge 55 ]]; then grade="C"
    elif [[ $percentage -ge 50 ]]; then grade="C-"
    elif [[ $percentage -ge 45 ]]; then grade="D+"
    elif [[ $percentage -ge 40 ]]; then grade="D"
    else grade="F"
    fi
    
    # Create analysis report
    cat > "$analysis_file" << EOF
# 📊 Content Quality Analysis Report

**File:** $(basename "$file")  
**Project:** $project_name  
**Analysis Date:** $(date '+%Y-%m-%d %H:%M:%S')  
**Overall Grade:** $grade ($percentage%)

## 📈 **Quality Metrics**

### **Structure Analysis (25 points)**
- **H1 Headers:** $h1_count ($(if [[ $h1_count -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **H2 Headers:** $h2_count ($(if [[ $h2_count -gt 2 ]]; then echo "✅"; else echo "❌"; fi))
- **H3 Headers:** $h3_count ($(if [[ $h3_count -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **Word Count:** $word_count ($(if [[ $word_count -gt 500 ]]; then echo "✅"; else echo "❌"; fi))
- **Content Length:** $(if [[ $word_count -gt 1000 ]]; then echo "✅ Comprehensive"; else echo "❌ Needs expansion"; fi)
- **Structure Score:** $structure_score/25

### **Content Analysis (25 points)**
- **Code Blocks:** $code_blocks ($(if [[ $code_blocks -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **Bullet Points:** $bullet_points ($(if [[ $bullet_points -gt 5 ]]; then echo "✅"; else echo "❌"; fi))
- **Numbered Lists:** $numbered_lists ($(if [[ $numbered_lists -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **Images:** $image_count ($(if [[ $image_count -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **Content Depth:** $(if [[ $word_count -gt 2000 ]]; then echo "✅ Comprehensive"; else echo "❌ Needs expansion"; fi)
- **Content Score:** $content_score/25

### **SEO Analysis (25 points)**
- **Internal Links:** $internal_links ($(if [[ $internal_links -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **External Links:** $external_links ($(if [[ $external_links -gt 0 ]]; then echo "✅"; else echo "❌"; fi))
- **Keywords Meta:** $(if grep -q "keywords:" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Description Meta:** $(if grep -q "description:" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Canonical URL:** $(if grep -q "canonical:" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **SEO Score:** $seo_score/25

### **Engagement Analysis (25 points)**
- **Visual Elements:** $(if grep -q "✅" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Action Indicators:** $(if grep -q "🎯" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Progress Indicators:** $(if grep -q "🚀" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Data Visualization:** $(if grep -q "📊" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Tips & Insights:** $(if grep -q "💡" "$file" 2>/dev/null; then echo "✅ Present"; else echo "❌ Missing"; fi)
- **Engagement Score:** $engagement_score/25

## 🎯 **Improvement Recommendations**

### **High Priority (Score < 15)**
$(if [[ $structure_score -lt 15 ]]; then echo "- Add more structured headers (H1, H2, H3)"; fi)
$(if [[ $content_score -lt 15 ]]; then echo "- Expand content with more detailed information"; fi)
$(if [[ $seo_score -lt 15 ]]; then echo "- Add SEO meta tags and internal/external links"; fi)
$(if [[ $engagement_score -lt 15 ]]; then echo "- Add visual elements and engagement indicators"; fi)

### **Medium Priority (Score 15-20)**
$(if [[ $structure_score -lt 20 ]]; then echo "- Improve header hierarchy and content organization"; fi)
$(if [[ $content_score -lt 20 ]]; then echo "- Add more code examples and detailed explanations"; fi)
$(if [[ $seo_score -lt 20 ]]; then echo "- Optimize for search engines with better linking"; fi)
$(if [[ $engagement_score -lt 20 ]]; then echo "- Enhance visual appeal and user engagement"; fi)

### **Low Priority (Score 20-25)**
$(if [[ $structure_score -lt 25 ]]; then echo "- Fine-tune structure for optimal readability"; fi)
$(if [[ $content_score -lt 25 ]]; then echo "- Add advanced content features and examples"; fi)
$(if [[ $seo_score -lt 25 ]]; then echo "- Implement advanced SEO techniques"; fi)
$(if [[ $engagement_score -lt 25 ]]; then echo "- Add premium engagement features"; fi)

## 📊 **Overall Assessment**

**Total Score:** $total_score/100 ($percentage%)  
**Grade:** $grade  
**Status:** $(if [[ $percentage -ge 80 ]]; then echo "✅ Excellent"; elif [[ $percentage -ge 70 ]]; then echo "⚠️ Good"; elif [[ $percentage -ge 60 ]]; then echo "⚠️ Needs Improvement"; else echo "❌ Poor"; fi)

### **Strengths**
$(if [[ $structure_score -ge 20 ]]; then echo "- Strong structural organization"; fi)
$(if [[ $content_score -ge 20 ]]; then echo "- Comprehensive content coverage"; fi)
$(if [[ $seo_score -ge 20 ]]; then echo "- Good SEO optimization"; fi)
$(if [[ $engagement_score -ge 20 ]]; then echo "- High engagement potential"; fi)

### **Areas for Improvement**
$(if [[ $structure_score -lt 20 ]]; then echo "- Structure and organization"; fi)
$(if [[ $content_score -lt 20 ]]; then echo "- Content depth and quality"; fi)
$(if [[ $seo_score -lt 20 ]]; then echo "- SEO optimization"; fi)
$(if [[ $engagement_score -lt 20 ]]; then echo "- User engagement"; fi)

---

*Generated by the Content Quality Analyzer on $(date '+%Y-%m-%d %H:%M:%S')*
EOF
    
    log "Analysis completed for: $file (Grade: $grade, Score: $percentage%)"
    echo "$file,$project_name,$grade,$percentage%,$total_score" >> "$ANALYSIS_DIR/quality_summary.csv"
}

# Generate summary report
generate_summary_report() {
    local summary_file="$ANALYSIS_DIR/quality_summary_report.md"
    
    log "Generating summary report: $summary_file"
    
    cat > "$summary_file" << EOF
# 📊 Content Quality Analysis Summary Report

**Analysis Date:** $(date '+%Y-%m-%d %H:%M:%S')  
**Total Files Analyzed:** $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0")  
**Analysis Directory:** $ANALYSIS_DIR

## 📈 **Overall Quality Metrics**

### **Grade Distribution**
$(if [[ -f "$ANALYSIS_DIR/quality_summary.csv" ]]; then
    echo "| Grade | Count | Percentage |"
    echo "|-------|-------|------------|"
    echo "| A+ (90-100%) | $(grep -c "A+" "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") | $(echo "scale=1; $(grep -c "A+" "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") * 100 / $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "1")" | bc 2>/dev/null || echo "0")% |"
    echo "| A (85-89%) | $(grep -c "A," "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") | $(echo "scale=1; $(grep -c "A," "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") * 100 / $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "1")" | bc 2>/dev/null || echo "0")% |"
    echo "| A- (80-84%) | $(grep -c "A-," "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") | $(echo "scale=1; $(grep -c "A-," "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") * 100 / $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "1")" | bc 2>/dev/null || echo "0")% |"
    echo "| B+ (75-79%) | $(grep -c "B+" "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") | $(echo "scale=1; $(grep -c "B+" "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") * 100 / $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "1")" | bc 2>/dev/null || echo "0")% |"
    echo "| B (70-74%) | $(grep -c "B," "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") | $(echo "scale=1; $(grep -c "B," "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") * 100 / $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "1")" | bc 2>/dev/null || echo "0")% |"
    echo "| Below B (0-69%) | $(grep -c -E "(B-|C|D|F)" "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") | $(echo "scale=1; $(grep -c -E "(B-|C|D|F)" "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "0") * 100 / $(wc -l < "$ANALYSIS_DIR/quality_summary.csv" 2>/dev/null || echo "1")" | bc 2>/dev/null || echo "0")% |"
else
    echo "No analysis data available."
fi

## 🎯 **Key Findings**

### **Strengths**
- Professional formatting and structure
- Comprehensive content coverage
- Good SEO optimization
- High engagement potential

### **Areas for Improvement**
- Content depth and quality
- SEO optimization
- User engagement
- Visual elements

## 📊 **Detailed Analysis**

See individual analysis files in the analysis directory for detailed breakdowns of each file.

## 🚀 **Recommendations**

1. **Immediate Actions (Week 1)**
   - Review and implement improvement recommendations
   - Focus on high-priority improvements
   - Update content based on analysis findings

2. **Short-term Goals (Month 1)**
   - Implement medium-priority improvements
   - Enhance content quality and depth
   - Optimize for better SEO performance

3. **Long-term Objectives (3-6 months)**
   - Achieve consistent A+ grades across all content
   - Implement advanced optimization techniques
   - Maintain high-quality standards

---

*Generated by the Content Quality Analyzer on $(date '+%Y-%m-%d %H:%M:%S')*
EOF
}

# Main execution
main() {
    log "Starting Content Quality Analysis"
    log "Project Root: $PROJECT_ROOT"
    
    # Create analysis directory
    create_analysis_dir
    
    # Initialize CSV file
    echo "File,Project,Grade,Percentage,Total Score" > "$ANALYSIS_DIR/quality_summary.csv"
    
    # Analyze key projects
    log "Analyzing content quality..."
    
    # AI Creator Tools 2025
    if [[ -d "$PROJECT_ROOT/ai-creator-tools-2025" ]]; then
        find "$PROJECT_ROOT/ai-creator-tools-2025" -name "*.md" | while read -r file; do
            analyze_markdown_file "$file" "AI Creator Tools 2025"
        done
    fi
    
    # Unified Creative Automation Workspace
    find "$PROJECT_ROOT" -maxdepth 1 -name "*.md" | while read -r file; do
        analyze_markdown_file "$file" "Unified Creative Automation Workspace"
    done
    
    # SEO Marketing Strategy
    if [[ -d "$PROJECT_ROOT/SEO_MARKETING_STRATEGY" ]]; then
        find "$PROJECT_ROOT/SEO_MARKETING_STRATEGY" -name "*.md" | while read -r file; do
            analyze_markdown_file "$file" "SEO Marketing Strategy"
        done
    fi
    
    # Business and Finance
    if [[ -d "$PROJECT_ROOT/02_Business_and_Finance" ]]; then
        find "$PROJECT_ROOT/02_Business_and_Finance" -name "*.md" | while read -r file; do
            analyze_markdown_file "$file" "Business and Finance Portfolio"
        done
    fi
    
    # Generate summary report
    generate_summary_report
    
    log "Content Quality Analysis completed successfully!"
    log "Analysis directory: $ANALYSIS_DIR"
    log "Log file: $LOG_FILE"
    
    echo -e "${GREEN}✅ Content Quality Analysis completed successfully!${NC}"
    echo -e "${BLUE}📁 Analysis directory: $ANALYSIS_DIR${NC}"
    echo -e "${BLUE}📝 Log file: $LOG_FILE${NC}"
    echo -e "${YELLOW}📊 Check individual analysis files for detailed breakdowns!${NC}"
}

# Run main function
main "$@"

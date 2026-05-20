# ~/scripts/sh/ Organization Index

## Directory Structure

### cleanup/ - Cleanup & Maintenance Utilities
Scripts for cleaning up caches, temporary files, and system maintenance.
- **Count**: See subdirectory
- **Examples**: cleanup.sh, cleanup_safe.sh, enhanced_cleanup.sh

### setup/ - Installation & Configuration
Scripts for setting up environments, installing dependencies, initializing systems.
- **Count**: See subdirectory
- **Examples**: setup.sh, setup-mamba.sh, setup_project.sh

### automation/ - Automation & Orchestration
Scripts that automate workflows, deployment, and orchestration.
- **Count**: See subdirectory
- **Examples**: deploy.sh, launch_automation.sh, auto_activate.sh

### audio_video/ - Audio & Video Processing
Scripts for processing, converting, and transcribing audio/video files.
- **Count**: See subdirectory
- **Examples**: transcribe.sh, process_music.sh, mp4-txt.sh

### utilities/ - General Utilities
Miscellaneous utility scripts that don't fit other categories.
- **Count**: See subdirectory
- **Examples**: Various general-purpose utilities

### processors/ - Data Processing & Transformation
Scripts for converting, compressing, and optimizing files.
- **Count**: See subdirectory
- **Examples**: convert_to_mp3.sh, optimize_pngs.sh, compress_videos.sh

### monitoring/ - Health & Diagnostic Checks
Scripts for monitoring system health, checking status, and diagnostics.
- **Count**: See subdirectory
- **Examples**: check_env_keys.sh, health_check.sh

### development/ - Development & Build Tools
Scripts for development, building, testing, and deployment.
- **Count**: See subdirectory
- **Examples**: build.sh, test.sh, deploy.sh

---

## Usage

To find a script, look for its function:
- Need to clean? → Check `cleanup/`
- Need to process audio? → Check `audio_video/`
- Need to deploy? → Check `automation/`

## Statistics

Run this to see counts:
```bash
for dir in */; do echo "$dir: $(ls -1 $dir*.sh 2>/dev/null | wc -l) scripts"; done
```

---

**Generated**: 2026-02-04  
**Organized by**: Advanced dependency analysis

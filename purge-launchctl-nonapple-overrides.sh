#!/usr/bin/env bash
# Bash 3.2 compatible. Purge listed non-Apple labels from ALL override DBs.
set -euo pipefail

# Labels still appearing in your last output (non-Apple only)
read -r -d '' LABELS <<'EOF'
com.vpn.itopmac.tools
com.micromat.ttm-daemon
TechtoolProSnapshotDaemon
com.iBoysoft.uninstallDaemon
com.micromat.techtoolpro20.TTP20BackgroundTool
com.stclairsoft.AppTamer.Helper
com.micromat.ttp-daemon.extra
com.adobe.AdobeCreativeCloud
com.cleverfiles.cfbackd
com.docker.socket
com.tunabellysoftware.TGFanHelper
com.cocoatech.PathFinder.SMFHelper7
com.MagnetismStudios.endurance.helper
com.micromat.TechtoolProSnapshotDaemon
Adobe_Genuine_Software_Integrity_Service
at.obdev.littlesnitch.daemon
com.docker.vmnetd
org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon
com.iobit.MBHelpToolerDaemon
com.macpaw.CleanMyMac-setapp.Agent
com.privateinternetaccess.vpn.daemon
com.crystalidea.macsfancontrol.smcwrite
org.xquartz.privileged_startx
com.bitgapp.eqmac.helper
org.pqrs.service.daemon.karabiner_grabber
com.daisydiskapp.DaisyDiskStandAlone.AdminHelper
com.bjango.istatmenus.daemon
com.iBoysoft.magicmenud
com.bjango.istatmenus.installer
com.adobe.acc.installer.v2
com.google.GoogleUpdater.wake.system
com.hegenberg.BetterTouchProcessPrioWatcher
us.zoom.ZoomDaemon
EOF

MY_UID="$(/usr/bin/id -u)"

# Known override databases across macOS versions (system + per-user)
OVERRIDE_PLISTS="
/var/db/com.apple.xpc.launchd/disabled.system.plist
/var/db/com.apple.xpc.launchd/disabled.plist
/var/db/com.apple.xpc.launchd/disabled.${MY_UID}.plist
/private/var/db/launchd.db/com.apple.launchd/overrides.plist
/private/var/db/launchd.db/com.apple.launchd.peruser.${MY_UID}/overrides.plist
"

LOG="$HOME/launchd_overrides_purge_$(date +%Y%m%d-%H%M%S).log"
say(){ echo -e "$@" | tee -a "$LOG"; }

say "🚀 Purging override entries for stray launchd labels…"

# 0) Make sure XML plists are writable and backed up before edits
backup_and_convert(){
  local plist="$1"
  [ ! -f "$plist" ] && return 0
  local backup="${plist}.bak.$(date +%Y%m%d-%H%M%S)"
  say "🗄  Backup: $plist -> $backup"
  sudo /bin/cp -p "$plist" "$backup" || true
  sudo /usr/bin/plutil -convert xml1 "$plist" 2>/dev/null || true
}

for dplist in $OVERRIDE_PLISTS; do
  [ -f "$dplist" ] && backup_and_convert "$dplist"
done

# 1) For each label: bootout + enable (clears state), then remove override key from ALL plists
printf "%s\n" "$LABELS" | while IFS= read -r label; do
  [ -z "$label" ] && continue
  case "$label" in com.apple.*) continue ;; esac

  say "\n=============================="
  say "🔎 Label: $label"

  # Unload by label (ignore failures)
  sudo launchctl bootout "system/$label" >/dev/null 2>&1 || true
  launchctl bootout "gui/$MY_UID/$label" >/dev/null 2>&1 || true

  # Clear runtime override state (enabled)
  sudo launchctl enable "system/$label" >/dev/null 2>&1 || true
  launchctl enable "gui/$MY_UID/$label"  >/dev/null 2>&1 || true

  # Remove override keys from every known overrides DB
  for dplist in $OVERRIDE_PLISTS; do
    if [ -f "$dplist" ]; then
      # Only attempt removal if key exists
      if sudo /usr/bin/plutil -extract "$label" xml1 -o - "$dplist" >/dev/null 2>&1; then
        say "🧽 Removing override from: $dplist"
        sudo /usr/bin/plutil -remove "$label" "$dplist" >/dev/null 2>&1 || true
      fi
    fi
  done

  # Also remove any lingering files (paranoia sweep)
  for p in /Library/LaunchDaemons /Library/LaunchAgents "$HOME/Library/LaunchAgents"; do
    [ -f "$p/$label.plist" ] && { say "🗑  rm $p/$label.plist"; sudo rm -f "$p/$label.plist" || true; }
  done
  helper="/Library/PrivilegedHelperTools/$label"
  [ -f "$helper" ] && { say "🗑  rm $helper"; sudo rm -f "$helper" || true; }

done

# 2) Hint launchd to refresh (safe)
sudo /usr/bin/killall -HUP launchd >/dev/null 2>&1 || true

say "\n✨ Done. Log: $LOG"
say "👉 Now run:  sudo launchctl print-disabled system"

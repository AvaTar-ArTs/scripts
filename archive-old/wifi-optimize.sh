#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Scan networks and recommend channels
echo "Scanning WiFi networks..."
sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s |
  awk 'NR>1 {
    split($4, chan, ",");
    if (chan[1] ~ /^[0-9]+$/) {
        channels[chan[1]]++;
        if ($1 ~ /[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}/) count++;
    }
  }
  END {
    print "\nNetworks found:", count;
    print "Channel congestion:";
    asorti(channels, sorted);
    for (i in sorted) {
        ch = sorted[i];
        printf "Channel %2d: %2d networks", ch, channels[ch];
        if (ch == 1 || ch == 6 || ch == 11) printf " (2.4GHz primary)";
        if (ch >= 36 && ch <= 165) printf " (5GHz)";
        print "";
    }
    
    # Find best 2.4GHz channel
    best24 = "";
    min24 = 1000;
    split("1 6 11", candidates);
    for (c in candidates) {
        ch = candidates[c];
        if (channels[ch] < min24) {
            min24 = channels[ch];
            best24 = ch;
        }
    }
    
    # Find best 5GHz channel
    best5 = "";
    min5 = 1000;
    for (ch = 36; ch <= 165; ch++) {
        if (ch in channels && channels[ch] < min5) {
            min5 = channels[ch];
            best5 = ch;
        }
    }
    
    print "\nRecommendations for Cox Gateway:";
    print "• 2.4GHz: Switch to Channel " best24 " (" min24 " networks)";
    print "• 5GHz:    Switch to Channel " best5 " (" min5 " networks)";
    print "\nNote: Avoid overlapping channels (use 1,6,11 for 2.4GHz)";
  }'

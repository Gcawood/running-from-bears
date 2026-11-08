#!/bin/bash
# Running From Bears — cabinet installer / updater (Batocera, Pi 4).
# Over SSH:   curl -sL https://gcawood.github.io/running-from-bears/cabinet/install.sh | bash
# Or on the cabinet: PORTS -> UPDATE RUNNING FROM BEARS
# Puts the files exactly where Batocera's Ports system expects them (high
# scores are kept) and refreshes the game list.
set -e
cd /userdata/roms/ports

# keep high scores across the reinstall
mkdir -p /tmp/rfb_keep
cp -f rfb/*hiscore* rfb/*.dat /tmp/rfb_keep/ 2>/dev/null || true

# remove leftovers from earlier versions, including nested-folder extractions
rm -rf rfb rfb_batocera_v1 rfb_batocera_v2 \
       RunningFromBears.sh RunningFromBearsClassic.sh README_ADAM.txt
rm -f gamelist.xml   # stale menu entries pointing at deleted files

echo "downloading..."
curl -sfL -o /tmp/rfb.zip "https://gcawood.github.io/running-from-bears/cabinet/rfb_batocera.zip?t=$(date +%s)"
unzip -o -q /tmp/rfb.zip -d /userdata/roms/ports
rm -f /tmp/rfb.zip
cp -f /tmp/rfb_keep/* rfb/ 2>/dev/null || true
chmod +x RunningFromBears*.sh UpdateRunningFromBears.sh rfb/bears* rfb/run_detached.sh
sync

# ask EmulationStation to rescan (works on Batocera v39+); harmless if not
curl -s http://localhost:1234/reloadgames >/dev/null 2>&1 || true

echo ""
echo "Installed $(head -1 rfb/VERSION 2>/dev/null):"
ls -la /userdata/roms/ports/RunningFromBears*.sh /userdata/roms/ports/rfb/
echo ""
echo "If the games don't appear under PORTS, update gamelists from the"
echo "menu (GAMES SETTINGS -> UPDATE GAMELISTS) or just reboot."

# The panel is a layer surface above slurp, so hide it before selecting a region.
swaync-client --close-panel
sleep 0.2

savedir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$savedir"
hyprshot --mode region --output-folder "$savedir"

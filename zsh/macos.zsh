## Macos-specific things

function  enable-wifi { networksetup -setairportpower en0 on }
function disable-wifi { networksetup -setairportpower en0 off }
function  toggle-wifi { disable-wifi; sleep 2; enable-wifi }

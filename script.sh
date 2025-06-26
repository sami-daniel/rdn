#!/bin/bash

# idk if there is some 'delay time' when cage starts, so we put 5s of delay
sleep 5s
wlr-randr --output HDMI-A-1 --transform 90 &
# again
sleep 5s
chromium --kiosk https://ooh.tvsimbrasil.com.br/ooh/current-ads \
        --noerrdialogs \
        --disable-infobars \
        --disable-session-crashed-bubble \
        --disable-translate \
        --no-first-run \
        --fast --fast-start --disable-features=TranslateUI \
        --start-fullscreen \
        --disable-pinch \
        --overscroll-history-navigation=0 \
        --disable-component-update \
        --disable-domain-reliability \
        --safebrowsing-disable-auto-update \
        --disable-client-side-phishing-detection \
        --metrics-recording-only

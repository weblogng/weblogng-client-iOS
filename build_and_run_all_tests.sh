#!/usr/bin/env bash
xctool.sh -workspace WNGLogger.xcworkspace -scheme logger -sdk iphonesimulator clean build test

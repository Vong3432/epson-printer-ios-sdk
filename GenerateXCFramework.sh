#!/bin/sh

# -------------- config --------------

# Uncomment for debugging
set -x

# Set bash script to exit immediately if any commands fail
set -e

moduleName="PrinterFramework"

iphoneosArchiveDirectoryPath="/$moduleName-iphoneos.xcarchive"
iphoneosArchiveDirectory="$( pwd; )$iphoneosArchiveDirectoryPath"

iphoneosArchiveDirectoryPath="/$moduleName-iphonesimulator.xcarchive"
iphoneosSimulatorDirectory="$( pwd; )$iphoneosArchiveDirectoryPath"

outputDirectory="$( pwd; )/$moduleName.xcframework"

## Cleanup
rm -rf $iphoneosArchiveDirectory
rm -rf $iphoneosSimulatorDirectory
rm -rf outputDirectory

# Archive
xcodebuild archive -scheme $moduleName \
     -archivePath $iphoneosArchiveDirectory \
     -destination "generic/platform=iOS" \
     SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
      
xcodebuild archive -scheme $moduleName \
     -archivePath $iphoneosSimulatorDirectory \
     -destination "generic/platform=iOS Simulator" \
     SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

## XCFramework
xcodebuild -create-xcframework \
    -framework "$iphoneosArchiveDirectory/Products/Library/Frameworks/$moduleName.framework" \
    -framework "$iphoneosSimulatorDirectory/Products/Library/Frameworks/$moduleName.framework" \
    -output $outputDirectory

## Cleanup
rm -rf $iphoneosArchiveDirectory
rm -rf $iphoneosSimulatorDirectory

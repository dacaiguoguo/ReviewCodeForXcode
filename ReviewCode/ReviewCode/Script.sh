#!/bin/sh

#  Script.sh
#  ReviewCode
#
#  Created by yanguo sun on 16/2/14.
#  Copyright © 2016年 sunyanguo. All rights reserved.
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID`
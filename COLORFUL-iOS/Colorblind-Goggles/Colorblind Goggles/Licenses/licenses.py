#!/usr/bin/env python3

#
#  licenses.py
#  Colorblind Goggles
#
#  Created by Edmund Dipple on 18/10/2020.
#  Copyright © 2020 Edmund Dipple. All rights reserved.
#

#  Use this script to generate the Acknowlegements strings and
#  plist files. One strings file and a plist per license.
#
#  Create a folder <project root>/Resources/Licenses and create a
#  .license file for each dependency acknowledgement in this folder.
#
#  Run this from the Licenses folder.
#
#  For each license, add the following to the
#  Settings.Bundle/Root.plist file
#  (replace LICENSE_NAME accordingly).
#
#        <dict>
#            <key>Type</key>
#            <string>PSChildPaneSpecifier</string>
#            <key>Title</key>
#            <string>LICENSE_NAME</string>
#            <key>File</key>
#            <string>LICENSE_NAME</string>
#        </dict>
#

import glob
import os
import re

stringsFile = '../../Settings.bundle/en.lproj/Acknowledgements.strings'
plistDir = '../../Settings.bundle/'

strings_data = ""

for license in glob.glob('*.license'):
    plist_data = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>StringsTable</key>
  <string>Acknowledgements</string>
  <key>PreferenceSpecifiers</key>
  <array>
"""
    if os.path.isfile(license):

        license_file = open(license, "r")
        license_data = license_file.read()
        license_file.close()

        license_data = re.sub("\r", "", license_data)
        license_data = re.sub("\n", "\r", license_data)
        license_data = re.sub("[ \t]+\r", "\r", license_data)
        license_data = re.sub("\"", "\'", license_data)

        key = license.replace(".license", "")
        count = 1

        for section in license_data.split("\r\r"):
            plistEntry = """<dict>
  <key>Type</key>
  <string>PSGroupSpecifier</string>
  <key>Title</key>
  <string>{0}</string>
</dict>
                """.format(key + str(count))
            plist_data += plistEntry
            strings_data += "\n\"{0}\" = \"{1}\";".format(key + str(count), section)
            count += 1

        plist_data += """</array>
</dict>
</plist>
"""

        plist_file = open(plistDir + key + '.plist', "w")
        plist_file.write(plist_data)
        plist_file.close()

strings_file = open(stringsFile, "w")
strings_file.write(strings_data)
strings_file.close()

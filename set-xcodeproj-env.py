import xml.etree.ElementTree as ETree
import getpass
from pbxproj import XcodeProject
import sys
import os

file = "Kognita.xcodeproj/xcshareddata/xcschemes/Run.xcscheme"

tree = ETree.parse(file)

def environmentVariable(name, value, etree, is_enabled=True):
  key = ETree.SubElement(etree, "EnvironmentVariable")
  key.attrib["key"] = name
  key.attrib["value"] = value
  if is_enabled:
    key.attrib["isEnabled"] = "YES"

# Adding Env variables
launchAction = tree.getroot().find("LaunchAction")
launchAction.set("useCustomWorkingDirectory", "YES")
launchAction.set("customWorkingDirectory", os.getcwd())

env_var_section = ETree.SubElement(launchAction, "EnvironmentVariables")

environmentVariable("MAILGUN_KEY", "dd", env_var_section)
environmentVariable("MAILGUN_DOMAIN", "dd", env_var_section)
environmentVariable("DATABASE_USER", getpass.getuser(), env_var_section)
environmentVariable("TEXT_CLIENT_BASE_URL", "127.0.0.1", env_var_section)
environmentVariable("TEXT_CLIENT_PORT", "5000", env_var_section)
environmentVariable("TEXT_CLIENT_SCHEME", "http", env_var_section)
environmentVariable("ROOT_URL", "http://localhost:8080", env_var_section)

tree.write(file)

# Adding swiftlint script
project = XcodeProject.load("Kognita.xcodeproj/project.pbxproj")
project.add_run_script("""
if which swiftlint >/dev/null; then
  swiftlint
  swiftlint autocorrect
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
""", target_name=["Run"])
project.save()

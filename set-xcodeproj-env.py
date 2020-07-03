import xml.etree.ElementTree as ETree
import getpass
from pbxproj import XcodeProject
import sys

file = "Kognita.xcodeproj/xcshareddata/xcschemes/Run.xcscheme"

tree = ETree.parse(file)

# Adding Env variables
env_var_section = ETree.SubElement(tree.getroot().find("LaunchAction"), "EnvironmentVariables")
mailgun_key = ETree.SubElement(env_var_section, "EnvironmentVariable")
mailgun_key.attrib["key"] = "MAILGUN_KEY"
mailgun_key.attrib["value"] = "dd"
mailgun_key.attrib["isEnabled"] = "YES"
mailgun_domain = ETree.SubElement(env_var_section, "EnvironmentVariable")
mailgun_domain.attrib["key"] = "MAILGUN_DOMAIN"
mailgun_domain.attrib["value"] = "dd"
mailgun_domain.attrib["isEnabled"] = "YES"
database_user = ETree.SubElement(env_var_section, "EnvironmentVariable")
database_user.attrib["key"] = "DATABASE_USER"
database_user.attrib["value"] = getpass.getuser()
database_user.attrib["isEnabled"] = "YES"

text_client_url = ETree.SubElement(env_var_section, "EnvironmentVariable")
text_client_url.attrib["key"] = "TEXT_CLIENT_BASE_URL"
text_client_url.attrib["value"] = "http://127.0.0.1:5000/"
text_client_url.attrib["isEnabled"] = "YES"

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

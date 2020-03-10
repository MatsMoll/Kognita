import xml.etree.ElementTree as ETree
import getpass

file = "Kognita.xcodeproj/xcshareddata/xcschemes/Run.xcscheme"

tree = ETree.parse(file)

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

tree.write(file)

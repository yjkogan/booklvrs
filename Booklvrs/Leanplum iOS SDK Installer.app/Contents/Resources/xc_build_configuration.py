# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class XCBuildConfiguration(object):
  """Represents build configuration object in Xcode."""
  
  SECTION_PATTERN = ('/\* Begin XCBuildConfiguration section \*/\n'
                     '(?P<xc_build_configuration_section>(.|\n)*)\n'
                     '/\* End XCBuildConfiguration section \*/')
  
  FILE_REFERENCE_PATTERN = (
      '\t\t(?P<hash_code>[A-F0-9]*) /\* (?P<name>(\S| )*) \*/ = {\n'
      '\t\t\tisa = (?P<class_name>\S*);\n'
      '(\t\t\tbaseConfigurationReference = (?P<base_ref>(\S| )*);\n)?'
      '\t\t\tbuildSettings = {\n'
      '(?P<build_settings>((\t\t\t\t\S* = (\S| )*;\n)|(\t\t\t\t\S* = '
      '\(\n(\t\t\t\t\t(\S| )*,\n)*\t\t\t\t\);\n))*)'
      '\t\t\t};\n'
      '\t\t\tname = (?P<alt_name>(\S| )*);\n'
      '\t\t};')
  
  BUILD_CONFIGURATION_PROPERTY_PATTERN = (
      '(?P<key_value>\t\t\t\t(?P<key>(\S| )*) = (?P<value>(\S| )*);\n)|'
      '(\t\t\t\t(?P<list_key>(\S| )*) = \(\n' 
      '(?P<property_value_list>(\t\t\t\t\t(\S| )*,\n)*)\t\t\t\t\);\n)')
  
  BUILD_CONFIGURATION_PROPERTY_LIST_LINE_PATTERN = (
      '\t\t\t\t\t(?P<value>(\S| )*),')
  
  STRING_REPRESENTATION = ('\t\t%s /* %s */ = {\n'
                           '\t\t\tisa = %s;\n'
                           '%s'
                           '\t\t\tbuildSettings = {\n'
                           '%s'
                           '\t\t\t};\n'
                           '\t\t\tname = %s;\n'
                           '\t\t};\n')
  
  STRING_PROPERTY_REPRESENTATION = '\t\t\t\t%s = %s;\n'
  
  STRING_MAIN_PROPERTY_REPRESENTATION = '\t\t\t%s = %s;\n'
  
  STRING_LIST_REPRESENTATION = '\t\t\t\t%s = (\n%s\t\t\t\t);\n'
  
  STRING_LIST_ITEM_REPRESENTATION = '\t\t\t\t\t%s,\n'

  def __init__(self, hash_code, name, class_name, build_settings, alt_name, 
               base_reference = None):
    """Initializes a XCBuildConfiguration object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      name: str, The name of the build configuration.
      class_name: str, The name of the class in Xcode (XCBuildConfiguration).
      build_settings: list, List with build settings information.
      alt_name: str, The alternative name of the build configuration.
      base_reference: str or None, The base configuration reference.
    """
    self.hash_code = hash_code
    self.name = name
    self.class_name = class_name
    self.build_settings = build_settings
    self.alt_name = alt_name
    self.base_reference = base_reference
    
  def __str__(self):
    """Generates the representation of the XCBuildConfiguration object."""
    return XCBuildConfiguration.STRING_REPRESENTATION % (
        self.hash_code, self.name, self.class_name, 
        self._get_property_line('baseConfigurationReference',
                                self.base_reference),
        self._generate_build_settings_string(), 
        self.alt_name)
    
  def _get_property_line(self, value, key):
    """Generates the representation of a property line.
    
    Args:
      value: str, The property value.
      key: str, The property key.
    
    Returns:
      str, The property line representation.
    """
    if key:
      return XCBuildConfiguration.STRING_MAIN_PROPERTY_REPRESENTATION % (value, 
                                                                         key)
    else:
      return ''
    
  def _generate_build_settings_string(self):
    """Generates the representation of a build settings."""
    strings_list = []
    for prop in self.build_settings:
      key = prop['key']
      value = prop['value']
      if isinstance(value, basestring):
        strings_list.append(XCBuildConfiguration.STRING_PROPERTY_REPRESENTATION 
                            % (key, value))
      else:
        strings_list.append(
            XCBuildConfiguration.STRING_LIST_REPRESENTATION % 
            (key, self._generate_build_settings_list_string(value)))
    return ''.join(strings_list)
  
  def _generate_build_settings_list_string(self, values):
    """Generates the representation of build settings list"""
    strings_list = []
    for value in values:
      strings_list.append(XCBuildConfiguration.STRING_LIST_ITEM_REPRESENTATION 
                          % value)
    return ''.join(strings_list)
  
  @staticmethod          
  def get_xc_build_configurations(data):
    """Parses a build configurations section inside the data.
    
    Args:
      data: str, The Xcode project file data.
    
    Returns:
      list, The Xcode build configurations.
    """
    xc_build_configurations = []
    match = re.search(XCBuildConfiguration.SECTION_PATTERN, data)
    if match:
      section = match.group('xc_build_configuration_section')
      match = re.findall(XCBuildConfiguration.FILE_REFERENCE_PATTERN, section)
      if match:
        for item in match:
          build_settings = []
          properties = re.findall(
              XCBuildConfiguration.BUILD_CONFIGURATION_PROPERTY_PATTERN, 
              item[7])
          for prop in properties:
            build_settings.append(
                XCBuildConfiguration._parse_build_configuration_property(prop))
          xc_build_configuration = XCBuildConfiguration(item[0], item[1], 
                                                        item[3], build_settings, 
                                                        item[14], item[5])
          xc_build_configurations.append(xc_build_configuration)
    return xc_build_configurations
  
  @staticmethod
  def _parse_build_configuration_property(configuration_property):
    """Parses a build configuration configuration_property section in the data.
    
    Args:
      configuration_property: str, The name of the configuration_property 
          section.
    
    Returns:
      dict, The configuration_property information.
    """
    build_settings_dict = {}
    if configuration_property[0]:
      build_settings_dict['key'] = configuration_property[1]
      build_settings_dict['value'] = configuration_property[3]
    else:
      build_settings_dict = {}
      build_settings_dict['key'] = configuration_property[6]
      build_settings_values = []
      for line in configuration_property[8].split('\n'):
        if line:
          build_settings_values.append(
            XCBuildConfiguration._parse_build_configuration_property_list_line(
              line))
      build_settings_dict['value'] = build_settings_values
    return build_settings_dict
  
  @staticmethod
  def _parse_build_configuration_property_list_line(line):
    """Parses a build configuration property list line.
    
    Args:
      line: str, The property list line.
    
    Returns:
      str, The property value.
    """
    value = None
    match = re.match(
      XCBuildConfiguration.BUILD_CONFIGURATION_PROPERTY_LIST_LINE_PATTERN, line)
    if match:
      value = match.group('value')
    return value
  
  def add_build_settings_property_list_values(self, key, values):
    """Adds build settings property list values into the property value list.
    
    Args:
      key: Property name.
      values: list,  Property list values.
    """
    for value in values:
      didAddValue = False
      for setting in self.build_settings:
        if setting['key'] == key:
          old_values = setting['value']
          if not isinstance(old_values, basestring):
            if value in old_values:
              didAddValue = True
              break
            else:
              old_values.append(value)
              didAddValue = True
              break
          else:
            old_values = [old_values] 
            old_values.append(value)
            setting['value'] = old_values
            didAddValue = True
            break
      if not didAddValue:
        self._add_new_build_settings_property_list_value(key, value)
    
  def _add_new_build_settings_property_list_value(self, key, value):
    """Adds build settings property list value into new property value list.
    
    Args:
      key: Property name.
      value: Property value.
    """
    index = 0
    for prop in self.build_settings:
      p_key = prop['key']
      if p_key[0] == '"':
        p_key = p_key[1:]
      if p_key < key:
        index = index + 1
    build_settings_dict = {
      'key': key,
      'value': [value]
    }
    self.build_settings.insert(index, build_settings_dict)

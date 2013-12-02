# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class XCConfigurationList(object):
  """Represents configuration list object in Xcode."""
  
  SECTION_PATTERN = ('/\* Begin XCConfigurationList section \*/\n'
                     '(?P<xc_configuration_list_section>(.|\n)*)\n'
                     '/\* End XCConfigurationList section \*/')
  
  FILE_REFERENCE_PATTERN = (
      '\t\t(?P<hash_code>[A-F0-9]*) '
      '/\* Build configuration list for (?P<target_class>\S*) '
      '"(?P<target_name>(\S| )*)" \*/ = {\n'
      '\t\t\tisa = (?P<class_name>\S*);\n'
      '\t\t\tbuildConfigurations = \(\n'
      '(?P<build_configurations>(\t\t\t\t[A-F0-9]* /\* (\S| )* \*/,\n)*)'
      '\t\t\t\);\n'
      '\t\t\tdefaultConfigurationIsVisible = '
      '(?P<default_configuration_is_visible>\S*);\n'
      '(\t\t\tdefaultConfigurationName = '
      '(?P<default_configuration_name>\S*);\n)?'
      '\t\t};')
  
  BUILD_CONFIGURATION_LIST_PATTERN = ('\t\t\t\t(?P<bc_hash_code>[A-F0-9]*) '
                                      '/\* (?P<bc_name>(\S| )*) \*/,')
  
  STRING_REPRESENTATION = ('\t\t%s /* Build configuration list for %s "%s" */ = {\n'
              '\t\t\tisa = %s;\n'
              '\t\t\tbuildConfigurations = (\n'
              '%s'
              '\t\t\t);\n'
              '\t\t\tdefaultConfigurationIsVisible = %s;\n'
              '%s'
              '\t\t};\n')
  
  STRING_PROPERTY_REPRESENTATION = '\t\t\t%s = %s;\n'
  
  STRING_BUILD_CONFIGURATION_REPRESENTATION = '\t\t\t\t%s /* %s */,\n'

  def __init__(self, hash_code, target_class, target_name, class_name,
               build_configurations, default_configuration_is_visible,
               default_configuration_name):
    """Initializes a XCConfigurationList object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      target_class: str, The class of the target (PBXProject, PBXNativeTarget).
      target_name: str, The name of the target.
      class_name: str, The name of the class in Xcode (XCConfigurationList).
      build_configurations: list, A list of build configuration information
          dictionaries.
      default_configuration_is_visible: str, If the default configuration is
          visible (0 or 1).
      default_configuration_name: str, The name of the default configuration.
    """
    self.hash_code = hash_code
    self.target_class = target_class
    self.target_name = target_name
    self.class_name = class_name
    self.build_configurations = build_configurations
    self.default_configuration_is_visible = default_configuration_is_visible
    self.default_configuration_name = default_configuration_name
    
  def __str__(self):
    """Generates the representation of the XCConfigurationList object."""
    return XCConfigurationList.STRING_REPRESENTATION % (self.hash_code, 
        self.target_class, 
        self.target_name, self.class_name, 
        self._generate_build_configuration_string(), 
        self.default_configuration_is_visible, 
        self._get_property_line('defaultConfigurationName', 
                                self.default_configuration_name))
  
  def _get_property_line(self, property_name, property_value):
    """Generates a property line representation."""
    if property_value:
      return (XCConfigurationList.STRING_PROPERTY_REPRESENTATION % 
          (property_name, property_value))
    else:
      return ''
    
  def _generate_build_configuration_string(self):
    """Generates a build configuration representation."""
    strings_list = []
    for bc_dict in self.build_configurations:
      strings_list.append(XCConfigurationList.
          STRING_BUILD_CONFIGURATION_REPRESENTATION % 
          (bc_dict['bc_hash_code'], bc_dict['bc_name']))
    return ''.join(strings_list)
  
  @staticmethod          
  def get_xc_configuration_lists(data):
    """Parses the XCode configuration lists section inside the data.
    
    Args:
      data: str, The Xcode project file data.
    
    Returns:
      list, The Xcode configuration lists.
    """
    xc_configuration_lists = []
    match = re.search(XCConfigurationList.SECTION_PATTERN, data)
    if match:
      section = match.group('xc_configuration_list_section')
      match = re.findall(XCConfigurationList.FILE_REFERENCE_PATTERN, section)
      if match:
        for xc_configuration_list_match in match:
          lines = xc_configuration_list_match[5].split('\n')
          build_configurations = []
          for line in lines:
            if line:
              build_configurations.append(
                XCConfigurationList._parse_build_configuration_line(line))
          xc_configuration_list = XCConfigurationList(
              xc_configuration_list_match[0], xc_configuration_list_match[1], 
              xc_configuration_list_match[2], xc_configuration_list_match[4], 
              build_configurations, xc_configuration_list_match[8], 
              xc_configuration_list_match[10])
          xc_configuration_lists.append(xc_configuration_list)
    return xc_configuration_lists
  
  @staticmethod
  def _parse_build_configuration_line(line):
    """Parses a XCode configuration list line.
    
    Args:
      line: str, The line to parse.
    
    Returns:
      dict, Build configuration information.
    """ 
    build_configuration_dict = {}
    match = re.match(XCConfigurationList.BUILD_CONFIGURATION_LIST_PATTERN, line)
    if match:
      build_configuration_dict['bc_hash_code'] = match.group('bc_hash_code')
      build_configuration_dict['bc_name'] = match.group('bc_name')
    return build_configuration_dict

# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class PBXGroup(object):
  """Represents group(folder) object in Xcode."""
  
  SECTION_PATTERN = ('/\* Begin PBXGroup section \*/\n'
                     '(?P<pbx_groups>(.|\n)*)\n'
                     '/\* End PBXGroup section \*/')
  
  END_SECTION_PATTERN = '/* End PBXGroup section */'
  
  FILE_REFERENCE_PATTERN = (
      '\t\t(?P<hash_code>[A-F0-9]*) (/\* (?P<name>(\S| )*) \*/ )?= {\n'
      '\t\t\tisa = (?P<class_name>\S*);\n'
      '\t\t\tchildren = \(\n'
      '(?P<children>(\t\t\t\t[A-F0-9]* /\* (\S| )* \*/,\n)*)'
      '\t\t\t\);\n'
      '(\t\t\tname = (?P<alt_name>(\S| )*);\n)?'
      '(\t\t\tpath = (?P<path>(\S| )*);\n)?'
      '\t\t\tsourceTree = (?P<source_tree>\S*);\n'
      '\t\t};')
  
  FILE_PATTERN = (
      '\t\t\t\t(?P<child_hash_code>[A-F0-9]*) /\* (?P<child_name>(\S| )*) \*/,') 
   
  CLASS_NAME = 'PBXGroup'
  
  STRING_REPRESENTATION = ('\t\t%s%s = {\n'
              '\t\t\tisa = %s;\n'
              '\t\t\tchildren = (\n'
              '%s'
              '\t\t\t);\n'
              '%s'
              '%s'
              '\t\t\tsourceTree = %s;\n'
              '\t\t};\n')
  
  STRING_NAME_REPRESENTATION = ' /* %s */'
  
  STRING_PROPERTY_LINE_REPRESENTATION = '\t\t\t%s = %s;\n'
  
  STRING_CHILD_LINE_REPRESENTATION = '\t\t\t\t%s /* %s */,\n'

  def __init__(self, hash_code, name, class_name, children, alt_name, path, 
               source_tree):
    """Initializes a PBXGroup object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      name: str, The name of the group.
      class_name: str, The name of the class in Xcode (PBXGroup).
      children: list, List with children dictionary information.
      alt_name: str, The alternative name of the group.
      path: str, The short path to the group.
      source_tree: str, The root directory from where the Xcode should start
          looking for the file.
    """
    self.hash_code = hash_code
    self.name = name
    self.class_name = class_name
    self.children = children
    self.alt_name = alt_name
    self.path = path
    self.source_tree = source_tree
  
  def __str__(self):
    return PBXGroup.STRING_REPRESENTATION % (
        self.hash_code, self._get_name_representation(), self.class_name, 
        self._generate_children_string(), 
        self._get_property_line('name', self.alt_name), 
        self._get_property_line('path', self.path), self.source_tree)
  
  def _get_name_representation(self):
    """Generates the representation of the name of PBXGroup object.
    
    This basically gives the "/* group_name */" string that corresponds to the 
    group name in the Xcode project file.
    
    Returns:
      str, The name.
    """
    if self.name:
      return PBXGroup.STRING_NAME_REPRESENTATION % self.name
    else:
      return ''
  
  def _get_property_line(self, key, value):
    """Generates the representation of a property line.
    
    Args:
      key: str, The property key.
      value: str, The property value.
    
    Returns:
      str, The property line.
    """
    if value:
      return PBXGroup.STRING_PROPERTY_LINE_REPRESENTATION % (key, value)
    else:
      return ''
    
  def _generate_children_string(self):
    """Generates the representation of the children of the group."""
    strings_list = []
    for child in self.children:
      strings_list.append(PBXGroup.STRING_CHILD_LINE_REPRESENTATION % 
                          (child['child_hash_code'], child['child_name']))
    return ''.join(strings_list)
        
  @staticmethod          
  def get_pbx_groups(data):
    """Parses the PBXGroups section inside the data.
    
    Args:
      data: str, The Xcode project file data.
    
    Returns:
      list, The PBXGroups.
    """
    pbx_groups = []
    match = re.search(PBXGroup.SECTION_PATTERN, data)
    if match:
      section = match.group('pbx_groups')
      match = re.findall(PBXGroup.FILE_REFERENCE_PATTERN, section)
      if match:
        for item in match:
          children_lines = item[5].split('\n')
          children = []
          for line in children_lines:
            if line:
              children.append(PBXGroup._parse_pbx_group_children_line(line))
          pbx_group = PBXGroup(item[0], item[2], item[4], children, 
                               item[9], item[12], item[14])
          pbx_groups.append(pbx_group)
    return pbx_groups
  
  @staticmethod
  def _parse_pbx_group_children_line(line):
    """Parses the a PBXGroups child line.
    
    Args:
      line: str, A child line.
    
    Returns:
      dict, Child information.
    """
    children_dict = {}
    match = re.match(PBXGroup.FILE_PATTERN, line)
    if match:
      children_dict['child_hash_code'] = match.group('child_hash_code')
      children_dict['child_name'] = match.group('child_name')
    return children_dict
  
  
  def add_child(self, child):
    """Adds a child to this PBXGroup object.
    
    Args:
      child: dict, The child information.
    """
    self.children.append(child)

# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class PBXBuildFile(object):
  """Represents build file object in Xcode."""
    
  SECTION_PATTERN = ('/\* Begin PBXBuildFile section \*/\n'
                     '(?P<PBXBuildFileSection>(.|\n)*)\n'
                     '/\* End PBXBuildFile section \*/')
  
  END_SECTION_PATTERN = '/* End PBXBuildFile section */'
  
  FILE_REFERENCE_PATTERN = (
      '\t\t(?P<hashcode>[A-F0-9]*) /\* (?P<name>(\S| )+) in (?P<group>\S*) '
      '\*/ = {isa = (?P<class_name>\S*); fileRef = '
      '(?P<file_reference_hash_code>\S*) /\* (?P<alt_name>(\S| )+) \*/;'
      '(?P<settings>(( settings = {.*};)|())) };')
  
  CLASS_NAME = 'PBXBuildFile'
  
  STRING_REPRESENTATION = ('\t\t%s /* %s in %s */ = {isa = %s; fileRef = %s '
                           '/* %s */;%s };\n')

  def __init__(self, hash_code, file_reference_hash_code, class_name, name, 
               alt_name, group, settings):
    """Initializes a PBXBuildFile object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      file_reference_hash_code: str, The file reference hashcode.
      class_name: str, The name of the class in Xcode (PBXBuildFile).
      name: str, The name of the build file.
      alt_name: str, The alternative name of the build file.
      group: str, The group to which the build file belongs.
      settings: str, Different settings (like weak reference).
    """
    self.hash_code = hash_code
    self.file_reference_hash_code = file_reference_hash_code
    self.class_name = class_name
    self.name = name
    self.alt_name = alt_name
    self.group = group
    self.settings = settings
    
  def __str__(self):
    return PBXBuildFile.STRING_REPRESENTATION % (self.hash_code, self.name, 
                                                 self.group, self.class_name, 
                                                 self.file_reference_hash_code, 
                                                 self.alt_name, self.settings)
    
  @staticmethod
  def get_pbx_build_files(data):
    """Parses the PBXBuildFiles section inside the data.
    
    Args:
      data: str, The Xcode project data.
    
    Returns:
      list, The PBXBuildFiles.
    """
    pbx_build_files = [] 
    match = re.search(PBXBuildFile.SECTION_PATTERN, data)
    if match:
      lines = match.group('PBXBuildFileSection').split('\n')
      for line in lines:
        pbx_build_files.append(PBXBuildFile._parse_pbx_build_file_line(line))
    return pbx_build_files
        
  @staticmethod      
  def _parse_pbx_build_file_line(line):
    """Parses the PBXBuildFile line.
    
    Args:
      line: str, The PBXBuildFile line.
    
    Returns:
      PBXBuildFile, A PBXBuildFile object.
    """
    pbx_build_file = None
    match = re.match(PBXBuildFile.FILE_REFERENCE_PATTERN, line)
    if match:
      pbx_build_file = PBXBuildFile(match.group('hashcode'), 
                                    match.group('file_reference_hash_code'),
                                    match.group('class_name'),
                                    match.group('name'), 
                                    match.group('alt_name'),
                                    match.group('group'),
                                    match.group('settings'))
    return pbx_build_file

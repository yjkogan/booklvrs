# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class PBXFileReference(object):
  """Represents file reference object in Xcode."""
  
  SECTION_PATTERN = ('/\* Begin PBXFileReference section \*/\n'
                     '(?P<PBXFileReferenceSection>(.|\n)*)\n'
                     '/\* End PBXFileReference section \*/')
  
  END_SECTION_PATTERN = '/* End PBXFileReference section */'
  
  FILE_REFERENCE_PATTERN = (
      '\t\t(?P<hashcode>[A-F0-9]*) '
      '/\* (?P<name>(\S| )+) \*/ = '
      '{isa = (?P<class_name>\S*); '
      '(includeInIndex = (?P<include_in_index_alt>\S*); )?'
      '(fileEncoding = (?P<file_encoding>\S*); )?'
      '(((lastKnownFileType = '
      '(?P<file_type>\S*))|(explicitFileType = (?P<explicit_file_type>\S*))); )?'
      '(fileEncoding = (?P<file_encoding_alt>\S*); )?'
      '(lineEnding = (?P<line_ending>\S*); )?'
      '(((includeInIndex = '
      '(?P<include_in_index>\S*))|(name = (?P<alt_name>(\S| )+))); )*'
      'path = (?P<path>(\S| )+); '
      'sourceTree = (?P<source_tree>\S*); '
      '(xcLanguageSpecificationIdentifier = (?P<xclsi>\S*); )?};')
  
  CLASS_NAME = 'PBXFileReference'
  
  STRING_REPRESENTATION = ('\t\t%s /* %s */ = {isa = %s;'
              ' %s%s%s%spath = %s; sourceTree = %s; %s};\n')
  
  STRING_PROPERTY_REPRESENTATION = '%s = %s; '

  def __init__(self, hash_code, class_name, name, alt_name, file_encoding,
               file_type, explicit_file_type, include_in_index, line_ending, 
               path, source_tree, xclsi = None):
    """Initializes a PBXFileReference object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      class_name: str, The name of the class in Xcode (PBXFileReference).
      name: str, The name of the file reference.
      alt_name: str, The alternative name of the file reference.
      file_encoding: str, The encoding of the file (number).
      file_type: str, The type of the file.
      explicit_file_type: str, The explicit file type.
      include_in_index: str, The index of the include (number).
      lineEnding: str, The line ending (number).
      path: str, The short path to the file.
      source_tree: str, The root directory from where the Xcode should start
          looking for the file.
      xclsi: str or None, The Xcode language specification identifier.
    """
    self.hash_code = hash_code
    self.class_name = class_name
    self.name = name
    self.alt_name = alt_name
    self.file_encoding = file_encoding
    self.file_type = file_type
    self.explicit_file_type = explicit_file_type
    self.include_in_index = include_in_index
    self.line_ending = line_ending
    self.path = path
    self.source_tree = source_tree
    self.xclsi = xclsi
    
  def __str__(self):
    """Generates the representation of the PBXFileReference object."""
    return (PBXFileReference.STRING_REPRESENTATION % 
        (self.hash_code, self.name, self.class_name, self._get_property_line(
             'fileEncoding', self.file_encoding), 
         self._get_file_type_representation(),
         self._get_property_line('lineEnding', self.line_ending), 
         self._get_property_line('name', self.alt_name), self.path, 
         self.source_tree, 
         self._get_property_line('xcLanguageSpecificationIdentifier', 
                                 self.xclsi)))
  
  def _get_file_type_representation(self):
    """Returns the type of the file reference.
    
    Returns:
      str, The file type.
    """
    if self.file_type:        
      result = self._get_property_line('lastKnownFileType', self.file_type)
      if self.include_in_index:
        result += self._get_property_line('includeInIndex', 
                                          self.include_in_index)
      return result
    elif self.explicit_file_type:
      return (self._get_property_line('explicitFileType', 
                                      self.explicit_file_type) 
              + self._get_property_line('includeInIndex', 
                                        self.include_in_index))
    else:
      return ''
  
  def _get_property_line(self, value, key):
    """Generates the representation of a property line.
    
    Args:
      value: str, The property value.
      key: str, The property key.
    
    Returns:
      str, The property line representation.
    """
    if key:
      return PBXFileReference.STRING_PROPERTY_REPRESENTATION % (value, key)
    else:
      return ''
        
  @staticmethod          
  def get_pbx_file_references(data):
    """Parses the PBXFileReferences section inside the data.
    
    Args:
      data: str, The Xcode project file data.
    
    Returns:
      list, The PBXFileReferences.
    """
    pbx_file_references = []
    match = re.search(PBXFileReference.SECTION_PATTERN, data)
    if match:
      lines = match.group('PBXFileReferenceSection').split('\n')
      for line in lines:
        pbx_file_references.append(
          PBXFileReference._parse_pbx_file_reference_line(line))
    return pbx_file_references
    
  @staticmethod  
  def _parse_pbx_file_reference_line(line):
    """Parses a PBXFileReference line inside the data.
    
    Args:
      data: str, The Xcode project file data.
    
    Returns:
      PBXFileReference, A PBXFileReference.
    """
    pbx_file_reference = None
    match = re.match(PBXFileReference.FILE_REFERENCE_PATTERN, line)
    if match:
      file_encoding = match.group('file_encoding')
      if not file_encoding:
        file_encoding = match.group('file_encoding_alt')
      include_in_index = match.group('include_in_index')
      if not include_in_index:
        include_in_index = match.group('include_in_index_alt')
      pbx_file_reference = PBXFileReference(match.group('hashcode'), 
                                            match.group('class_name'),
                                            match.group('name'), 
                                            match.group('alt_name'),
                                            file_encoding,
                                            match.group('file_type'),
                                            match.group('explicit_file_type'),
                                            include_in_index,
                                            match.group('line_ending'),
                                            match.group('path'),
                                            match.group('source_tree'),
                                            match.group('xclsi'))
    return pbx_file_reference

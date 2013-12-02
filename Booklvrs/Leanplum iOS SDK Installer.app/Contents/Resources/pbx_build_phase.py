# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class PBXBuildPhase(object):
  """Represents build phase object in Xcode.
  
  There are multiple types of build phase objects - Frameworks, Resources, 
  Sources.  
  """
  
  SECTION_PATTERN = ('/\* Begin PBX{0}BuildPhase section \*/\n'
                     '(?P<pbx_build_phase>(.|\n)*)\n'
                     '/\* End PBX{0}BuildPhase section \*/')
  
  BUILD_PHASE_PATTERN = (
      '\t\t(?P<hash_code>[A-F0-9]*) /\* (?P<phase>\S*) \*/ = {\n'
      '\t\t\tisa = (?P<class_name>\S*);\n'
      '\t\t\tbuildActionMask = (?P<build_action_mask>\S*);\n'
      '\t\t\tfiles = \(\n'
      '(?P<file>(\t\t\t\t[A-F0-9]* /\* (\S| )* in \S* \*/,\n)*)'
      '\t\t\t\);\n'
      '\t\t\trunOnlyForDeploymentPostprocessing = '
      '(?P<run_only_for_deployment_postprocessing>\S*);\n'
      '\t\t};')
  
  FILE_PATTERN = ('\t\t\t\t(?P<file_hash_code>[A-F0-9]*) '
                  '/\* (?P<file_name>(\S| )*) in (?P<file_phase>\S*) \*/,')
  
  STRING_REPRESENTATION = (
      '\t\t%s /* %s */ = {\n'
      '\t\t\tisa = %s;\n'
      '\t\t\tbuildActionMask = %s;\n'
      '\t\t\tfiles = (\n%s\t\t\t);\n'
      '\t\t\trunOnlyForDeploymentPostprocessing = %s;\n'
      '\t\t};\n')
  
  FILE_STRING_REPRESENTATION = ('\t\t\t\t%s /* %s in %s */,\n')

  def __init__(self, hash_code, phase, class_name, build_action_mask, files,
               run_only_for_deployment_postprocessing):
    """Initializes a PBXBuildPhase object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      phase: str, The name of the build phase (Framework, Resources, Sources).
      class_name: str, The name of the class in Xcode (PBXBuildPhase).
      build_action_mask: str, The build action mask.
      files: list, List of file info dicts.
      run_only_for_deployment_postprocessing: str, If it runs only for 
          development post processing - ("0" or "1").
    """
    self.hash_code = hash_code
    self.phase = phase
    self.class_name = class_name
    self.build_action_mask = build_action_mask
    self.files = files
    self.run_only_for_deployment_postprocessing = (
        run_only_for_deployment_postprocessing)
    
  def __str__(self):
    return PBXBuildPhase.STRING_REPRESENTATION % (
        self.hash_code, self.phase, self.class_name, 
        self.build_action_mask, self._generate_files_string(), 
        self.run_only_for_deployment_postprocessing)
    
  def _generate_files_string(self):
    """Generates the representation of a file inside a build phase."""
    result = []
    for file_dict in self.files:
      result.append(PBXBuildPhase.FILE_STRING_REPRESENTATION % 
          (file_dict['file_hash_code'], 
           file_dict['file_name'], 
           file_dict['file_phase']))
    return ''.join(result)
        
  @staticmethod          
  def get_pbx_build_phases(data, phase):
    """Parses the PBX{phase}BuildPhase section inside the data.
    
    Args:
      data: str, The Xcode project file data.
      phase: str, The name of the phase
    
    Returns:
      list, The PBXBuildPhases.
    """
    pbx_build_phases = []
    match = re.search(PBXBuildPhase.SECTION_PATTERN.format(phase), data)
    if match:
      section = match.group('pbx_build_phase')
      match = re.findall(PBXBuildPhase.BUILD_PHASE_PATTERN, section)
      if match:
        for pbx_build_phase_match in match:
          file_lines = pbx_build_phase_match[4].split('\n')
          files = []
          for line in file_lines:
            if line:
              files.append(PBXBuildPhase._parse_pbx_build_phase_file_line(line))
          pbx_build_phase = PBXBuildPhase(
              pbx_build_phase_match[0], pbx_build_phase_match[1], 
              pbx_build_phase_match[2], pbx_build_phase_match[3], 
              files, pbx_build_phase_match[7])
          pbx_build_phases.append(pbx_build_phase)
    return pbx_build_phases
  
  @staticmethod
  def _parse_pbx_build_phase_file_line(line):
    """Parses a PBXBuildPhase file line.
    
    Args:
      line: str, The file line.
    
    Returns:
      dict, The file data.
    """
    file_dict = {}
    match = re.match(PBXBuildPhase.FILE_PATTERN, line)
    if match:
      file_dict['file_hash_code'] = match.group('file_hash_code')
      file_dict['file_name'] = match.group('file_name')
      file_dict['file_phase'] = match.group('file_phase')
    return file_dict
  
  def add_file(self, file_dict):
    """Adds a file into the build phase.
    
    Args:
      file_dict: dict, The file information.
    """
    self.files.append(file_dict)

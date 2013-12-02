# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import hashlib
import os
import re


import pbx_build_file
import pbx_file_reference
import pbx_build_phase
import pbx_group
import xc_configuration_list
import xc_build_configuration


class PBXProjectFile(object):
  """Represents the PBXProjectFile object.
  
  This object finds place in the .pbxproj file in your Xcode project.
  """
  
  MAIN_GROUP_PATTERN = ('/\* Begin PBXProject section \*/\n'
                        '(.|\n)*'
                        'mainGroup = (?P<main_group_hashcode>(\S)*)'
                        '( /\* (?P<main_group_name>(\S| )*) \*/)?;'
                        '(.|\n)*'
                        '/\* End PBXProject section \*/')
  
  FILE_ENCODING = '4'

  def __init__(self, project_config):
    self._project_config = project_config
    if os.path.exists(project_config.pbx_project_file_path):
      with open(project_config.pbx_project_file_path) as project_file:
        self._project_file_data = project_file.read()
        self._pbx_build_files = (
            pbx_build_file.PBXBuildFile.get_pbx_build_files(
                self._project_file_data))
        print('  Build file references found.\n')
        self._pbx_file_references = (
            pbx_file_reference.PBXFileReference.get_pbx_file_references(
                self._project_file_data))
        print('  File references found.\n')
        self._pbx_framework_build_phases = (
            pbx_build_phase.PBXBuildPhase.get_pbx_build_phases(
                self._project_file_data, 'Frameworks'))
        print('  Frameworks found.\n')
        self._pbx_groups = pbx_group.PBXGroup.get_pbx_groups(
            self._project_file_data)
        print('  Groups found.\n')
        self._xc_configuration_lists = (
            xc_configuration_list.XCConfigurationList.
                get_xc_configuration_lists(self._project_file_data))
        print('  Xcode configurations found.\n')
        self._xc_build_configurations = (
            xc_build_configuration.XCBuildConfiguration.
                get_xc_build_configurations(self._project_file_data))
        print('  Xcode build configurations found.\n')
        self._leanplum_hash_codes = LeanplumHashCodes(
            len(self._pbx_framework_build_phases))
        if not self._project_config.main_group:
          self._project_config.main_group = self._find_main_group()
        
  def _find_main_group(self):
    """Finds the name of the main group(folder) in the project."""
    match = re.search(self.MAIN_GROUP_PATTERN, self._project_file_data)
    if (match and 
        match.group('main_group_name')):
      return match.group('main_group_name')
    return ''
          
  def install(self):
    """Installs the Leanplum sdk."""
    self._add_build_file_references()
    print('  Build file references added.\n')
    self._add_file_references()
    print('  File references added.\n')
    self._add_files_to_build_phases()
    print('  Files added to build phases.\n')
    self._add_files_to_project()
    print('  Files added to the project.\n')
    self._add_leanplum_paths_to_build_configurations(
        self._project_config.main_group)
    print('  Paths added to build configurations.\n')
    self._add_other_linker_flags()
    print('  Other linker flags added.\n')
      
  def save(self):
    """Saves the changes to the project file."""
    project_file = open(self._project_config.pbx_project_file_path, 'w')
    project_file.write(self._project_file_data)
    project_file.close()
  
  def _add_build_file_references(self):
    """Adds the build file references for the Leanplum files."""
    self._add_build_file(
        'libLeanplum.a', self._leanplum_hash_codes.leanplum_a_build_references, 
        self._leanplum_hash_codes.leanplum_a_file_reference, '')
    self._add_build_file(
        'CFNetwork.framework', 
        self._leanplum_hash_codes.cf_network_build_references, 
        self._leanplum_hash_codes.cf_network_file_reference, '')
    self._add_build_file(
        'SystemConfiguration.framework', 
        self._leanplum_hash_codes.system_configuration_build_references, 
        self._leanplum_hash_codes.system_configuration_file_reference, '')
    self._add_build_file(
        'Security.framework', 
        self._leanplum_hash_codes.security_build_references, 
        self._leanplum_hash_codes.security_file_reference, '')
    self._add_build_file(
        'AdSupport.framework', 
        self._leanplum_hash_codes.ad_support_build_references, 
        self._leanplum_hash_codes.ad_support_file_reference,
        ' settings = {ATTRIBUTES = (Weak, ); };')    
        
  def _add_build_file(self, file_name, build_hash_codes, file_hash_code, settings):
    """Adds the build references for a given file.
  
    Args:
      file_name: str, The name of the file.
      build_hash_codes: list, The build hash codes (i.e. IDs) (1 for each target).
      file_hash_code: str, The file hash code (i.e. ID).
    """
    if self._contains_build_file(file_name):
      return
    for hash_code in build_hash_codes:
      build_file = pbx_build_file.PBXBuildFile(
          hash_code, file_hash_code,
          pbx_build_file.PBXBuildFile.CLASS_NAME, file_name, file_name, 
          'Frameworks', settings)
      self._add_pbx_build_file(build_file)
      self._pbx_build_files.append(build_file)
    
  def _contains_build_file(self, name):
    """Checks if there is already build reference for this file."""
    for build_file in self._pbx_build_files:
      if build_file.name == name:
        return True
    return False
  
  def _add_pbx_build_file(self, build_file):
    """Adds PBXBuildFile into the data.
    
    Args:
      build_file: PBXBuildFile, The PBXBuildFile object.
    """
    build_files_end_section_pattern = re.escape(
        pbx_build_file.PBXBuildFile.END_SECTION_PATTERN)
    build_files_end_section_replace_string = (str(build_file) +
        pbx_build_file.PBXBuildFile.END_SECTION_PATTERN)
    
    self._project_file_data = re.sub(build_files_end_section_pattern, 
                                     build_files_end_section_replace_string, 
                                     self._project_file_data)
  
  def _add_file_references(self):
    """Adds the file references for the Leanplum files."""
    self._add_file_reference(
        self._leanplum_hash_codes.leanplum_a_file_reference,
        'libLeanplum.a', '', '', 'archive.ar', 'libLeanplum.a', '"<group>"')
    self._add_file_reference(
        self._leanplum_hash_codes.leanplum_h_file_reference, 
        'Leanplum.h', '', self.FILE_ENCODING, 'sourcecode.c.h', 'Leanplum.h', 
        '"<group>"')
    self._add_file_reference(
        self._leanplum_hash_codes.cf_network_file_reference, 
        'CFNetwork.framework', 'CFNetwork.framework', '', 'wrapper.framework', 
        'System/Library/Frameworks/CFNetwork.framework', 'SDKROOT')
    self._add_file_reference(
        self._leanplum_hash_codes.system_configuration_file_reference, 
        'SystemConfiguration.framework', 'SystemConfiguration.framework', '', 
        'wrapper.framework', 
        'System/Library/Frameworks/SystemConfiguration.framework', 'SDKROOT')
    self._add_file_reference(
        self._leanplum_hash_codes.security_file_reference, 
        'Security.framework', 'Security.framework', '', 'wrapper.framework', 
        'System/Library/Frameworks/Security.framework', 'SDKROOT')
    self._add_file_reference(
        self._leanplum_hash_codes.ad_support_file_reference, 
        'AdSupport.framework', 'AdSupport.framework', '', 'wrapper.framework', 
        'System/Library/Frameworks/AdSupport.framework', 'SDKROOT')
  
  def _add_file_reference(self, hash_code, name, alt_name, encoding, 
                          file_type, path, source_tree):
    """Adds the file reference for a given file.
  
    Args:
      hash_code: str, The file hash code (i.e. ID).
      name: str, The file name.
      alt_name: str, The alternative file name.
      encoding: str, The file encoding.
      file_type: str, The file type.
      path: str, The file path.
      source_tree: str, The source tree code.
    """
    if self._contains_file_reference(name):
      return
    else:
      leanplum_file_reference = pbx_file_reference.PBXFileReference(
          hash_code, pbx_file_reference.PBXFileReference.CLASS_NAME, name, 
          alt_name, encoding, file_type, '', '', '', path, source_tree)
      self._add_pbx_file_reference(leanplum_file_reference)
      self._pbx_file_references.append(leanplum_file_reference)
  
  def _contains_file_reference(self, name):
    """Checks if there is already file reference for this file."""
    for file_reference in self._pbx_file_references:
      if file_reference.name == name:
        return True
    return False
  
  def _add_pbx_file_reference(self, file_reference):
    """Adds PBXFileReference into the data.
    
    Args:
      file_reference: PBXFileReference, The PBXFileReference object.
    """
    file_reference_end_section_pattern = re.escape(
        pbx_file_reference.PBXFileReference.END_SECTION_PATTERN)
    file_reference_end_section_replace_string = (
        str(file_reference) + 
        pbx_file_reference.PBXFileReference.END_SECTION_PATTERN)
    self._project_file_data = re.sub(file_reference_end_section_pattern, 
                                     file_reference_end_section_replace_string, 
                                     self._project_file_data)
  
  def _add_files_to_build_phases(self):
    """Adds the files to the different build phases"""
    self._add_file_to_build_phases(
        'libLeanplum.a', self._leanplum_hash_codes.leanplum_a_build_references)
    self._add_file_to_build_phases(
        'CFNetwork.framework', 
        self._leanplum_hash_codes.cf_network_build_references)
    self._add_file_to_build_phases(
        'SystemConfiguration.framework', 
        self._leanplum_hash_codes.system_configuration_build_references)
    self._add_file_to_build_phases(
        'Security.framework', 
        self._leanplum_hash_codes.security_build_references)
    self._add_file_to_build_phases(
        'AdSupport.framework', 
        self._leanplum_hash_codes.ad_support_build_references)
  
  def _add_file_to_build_phases(self, name, hash_codes):
    """Adds a file to all the build phases
  
    Args:
      name: str, The file name.
      hash_code: str, the file hash code - ID.
    """
    for index, build_phase in enumerate(self._pbx_framework_build_phases):
      should_add = True
      for build_phase_file in build_phase.files:
        if build_phase_file['file_name'] == name:
          should_add = False
          break
      if should_add:
        self._add_file_to_build_phase(build_phase, name, hash_codes, index)
        
  def _add_file_to_build_phase(self, build_phase, name, hash_codes, index):
    """Adds a file to a build phase
  
    Args:
      build_phase: PBXBuildPhase, The PBXBuildPhase object.
      hash_codes: list, The file build hash codes (i.e. IDs).
      name: str, The file name.
      index: int, The number of the hash code to be used.
    """
    file_dict = {}
    file_dict['file_hash_code'] = hash_codes[index]
    file_dict['file_name'] = name
    file_dict['file_phase'] = 'Frameworks'
    self._add_file_to_pbx_build_phase(build_phase, file_dict)
    
  def _add_file_to_pbx_build_phase(self, build_phase, file_dict):
    """Adds a new PBXBuildPhase file line into the data.
    
    Args:
      build_phase: PBXBuildPhase, The PBXBuildPhase object.
      file_dict: dict, The file data.
    """
    build_phase_representation = re.escape(str(build_phase))
    build_phase.add_file(file_dict)
    new_build_phase_representation = str(build_phase)
    self._project_file_data = re.sub(build_phase_representation, 
                                     new_build_phase_representation, 
                                     self._project_file_data) 
     
  def _add_files_to_project(self):
    """Adds the frameworks and the Leanplum files to the project group"""
    self._add_file_to_group(self._project_config.main_group, 
                            'Leanplum', 
                            self._leanplum_hash_codes.leanplum_group_reference)
    # Sometimes there is no Frameworks group, but if there is it is the best 
    # place to add the frameworks in. We use the main project group if the
    # Frameworks group is missing.
    if not self._add_file_to_group('Frameworks', 'CFNetwork.framework', 
        self._leanplum_hash_codes.cf_network_file_reference):
      self._add_file_to_group(
          self._project_config.main_group, 'CFNetwork.framework', 
          self._leanplum_hash_codes.cf_network_file_reference)
    if not self._add_file_to_group('Frameworks', 'SystemConfiguration.framework', 
        self._leanplum_hash_codes.system_configuration_file_reference):
      self._add_file_to_group(self._project_config.main_group, 
          'SystemConfiguration.framework', 
          self._leanplum_hash_codes.system_configuration_file_reference)
    if not self._add_file_to_group('Frameworks', 'Security.framework', 
        self._leanplum_hash_codes.security_file_reference):
      self._add_file_to_group(self._project_config.main_group, 
          'Security.framework', 
          self._leanplum_hash_codes.security_file_reference)
    if not self._add_file_to_group('Frameworks', 'AdSupport.framework', 
        self._leanplum_hash_codes.ad_support_file_reference):
      self._add_file_to_group(self._project_config.main_group, 
          'AdSupport.framework', 
          self._leanplum_hash_codes.ad_support_file_reference)
    self._add_leanplum_files_to_leanplum_group()
       
  def _add_file_to_group(self, group_name, file_name, hash_code):
    """Adds a file to a PBXGroup
  
    Args:
      group_name: str, the name of the group.
      hash_code: str, the file hash code - ID.
      file_name: str, the file name.
      
    Returns:
      bool, If the operation was completed successfully.
    """ 
    for group in self._pbx_groups:
      if group.name == group_name:
        for child in group.children:
          if child['child_name'] == file_name:
            return True
        child = {}
        child['child_hash_code'] = hash_code
        child['child_name'] = file_name
        self._add_pbx_group_child(child, group)
        return True
    return False
      
  def _add_leanplum_files_to_leanplum_group(self):
    """Adds the Leanplum files to the Leanplum group"""
    for group in self._pbx_groups:
      if group.name == 'Leanplum':
        return
    children = [
      {
        'child_hash_code': self._leanplum_hash_codes.leanplum_h_file_reference,
        'child_name': 'Leanplum.h'
      }, {
        'child_hash_code': self._leanplum_hash_codes.leanplum_a_file_reference,
        'child_name': 'libLeanplum.a'
      }
    ]
    leanplum_group = pbx_group.PBXGroup(
        self._leanplum_hash_codes.leanplum_group_reference, 'Leanplum', 
        pbx_group.PBXGroup.CLASS_NAME, children, '', 'Leanplum', '"<group>"')
    self._add_pbx_group(leanplum_group)
    self._pbx_groups.append(leanplum_group)  
    
  def _add_pbx_group_child(self, child, group):
    """Adds a PBXGroup child into the data.
    
    Args:
      child: dict, The child information.
      group: PBXGroup, The PBXGroup object.
    """
    group_representation = re.escape(str(group))
    group.add_child(child)
    new_group_representation = str(group)
    self._project_file_data = re.sub(group_representation, 
                                     new_group_representation, 
                                     self._project_file_data)
  
  def _add_pbx_group(self, group):
    """Adds a PBXGroup into the data.
    
    Args:
      group: PBXGroup, The PBXGroup object.
    """
    group_end_section_pattern = re.escape(
        pbx_group.PBXGroup.END_SECTION_PATTERN)
    group_end_section_replace_string = (
        str(group) + pbx_group.PBXGroup.END_SECTION_PATTERN)
    self._project_file_data = re.sub(group_end_section_pattern, 
                                     group_end_section_replace_string, 
                                     self._project_file_data)
    
  def _add_leanplum_paths_to_build_configurations(self, project_folder_name):
    """Adds the Leanplum paths to the build configurations
    
    Args:
      project_folder_name: str, The project folder name.
    """
    if project_folder_name == 'CustomTemplate':
      project_folder_name = ''
    leanplum_library_path = os.path.normpath((
        '"\\"$(SRCROOT)/{0}/Leanplum\\""'.format(project_folder_name)))
    self._add_settings_to_build_configurations(
        'LIBRARY_SEARCH_PATHS', 
        ['"$(inherited)"', leanplum_library_path.replace(' ','\\\\ ')])
  
  def _add_other_linker_flags(self):
    """Adds the Other linker flags to the build configurations"""
    self._add_settings_to_build_configurations('OTHER_LDFLAGS', 
                                               ['"-ObjC"','"-fobjc"','"-arc"'])
   
  def _add_settings_to_build_configurations(self, prop, values):
    """Adds a setting to the build configurations
    
    Args:
      prop: str, The name of the setting that needs to be added.
      values: list, The different values for the property.
    """
    hash_codes = []
    for xc_configuration_list in self._xc_configuration_lists:
      if xc_configuration_list.target_class == 'PBXNativeTarget':
        for build_configuration in xc_configuration_list.build_configurations:
          hash_codes.append(build_configuration['bc_hash_code'])
    for build_configuration in self._xc_build_configurations:
      if build_configuration.hash_code in hash_codes:
        self._add_settings_to_xc_build_configuration(build_configuration, prop, 
                                                     values)

  def _add_settings_to_xc_build_configuration(self, build_configuration, prop, 
                                              values):
    """Adds a new PBXBuildConfiguration property list into the data.
    
    Args:
      build_configuration: XCBuildConfiguration, The XCBuildConfiguration object.
      prop: str, The property name.
      value: list, The list of the property values.
    """
    build_configuration_representation = re.escape(str(build_configuration))
    build_configuration.add_build_settings_property_list_values(prop, values)
    new_build_configuration_representation = str(build_configuration)      
    self._project_file_data = re.sub(
        build_configuration_representation, 
        new_build_configuration_representation.replace('\\', '\\\\'), 
        self._project_file_data)

class LeanplumHashCodes(object):
  """
  This class is responsible for generating the Leanplum hashcodes. 
  The hashcodes for the Leanplum files, that will be added to the iOS project.
  These hashcodes are unique identifiers that will be used by
  Xcode to distinguish them as unique objects while parsing the project file.
  """
  
  HASH_LENGTH = 24
  
  def __init__(self, build_ref_number):
    self.leanplum_h_file_reference = ''
    self.leanplum_a_file_reference = ''
    self.leanplum_a_build_references = []
    self.leanplum_group_reference = ''
    self.cf_network_file_reference = ''
    self.cf_network_build_references = []
    self.system_configuration_file_reference = ''
    self.system_configuration_build_references = []
    self.security_file_reference = ''
    self.security_build_references = []
    self.ad_support_file_reference = ''
    self.ad_support_build_references = []
    self._generate_leanplum_hash_codes(build_ref_number)
  
  def _generate_leanplum_hash_codes(self, build_ref_number):
    """Generates the hashcodes needed for Object IDs.
    
    Args:
      build_ref_number: str, the number of build reference hashcodes that need 
          to be generated. One for each build reference for each target. Example:
          If we have 2 Xcode build targets this means build_ref_number = 2
    """
    self.leanplum_h_file_reference = self._generate_leanplum_hash_code(
        'leanplum_h_file_reference')
    self.leanplum_a_file_reference = self._generate_leanplum_hash_code(
        'leanplum_a_file_reference')
    self.cf_network_file_reference = self._generate_leanplum_hash_code(
        'cf_network_file_reference')
    self.system_configuration_file_reference = self._generate_leanplum_hash_code(
        'system_configuration_file_reference')
    self.security_file_reference = self._generate_leanplum_hash_code(
        'security_file_reference')
    self.ad_support_file_reference = self._generate_leanplum_hash_code(
        'ad_support_file_reference')
    for i in range(build_ref_number):
      self.leanplum_a_build_references.append(
          self._generate_leanplum_hash_code('leanplum_a_build_references' + 
                                            str(i)))
      self.cf_network_build_references.append(
          self._generate_leanplum_hash_code('cf_network_build_references' + 
                                            str(i)))
      self.system_configuration_build_references.append(
          self._generate_leanplum_hash_code(
              'system_configuration_build_references' + str(i)))
      self.security_build_references.append(
          self._generate_leanplum_hash_code('security_build_references' + 
                                            str(i)))
      self.ad_support_build_references.append(
          self._generate_leanplum_hash_code('ad_support_build_references' + 
                                            str(i)))
    self.leanplum_group_reference = self._generate_leanplum_hash_code(
        'leanplum_group_reference')
        
  def _generate_leanplum_hash_code(self, string):
    return hashlib.sha224(string).hexdigest().upper()[:self.HASH_LENGTH]

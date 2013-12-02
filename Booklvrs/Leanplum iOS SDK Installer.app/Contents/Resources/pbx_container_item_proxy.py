# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class PBXContainerItemProxy(object):
  """Represents container item proxy object in Xcode."""
  
  SECTION_PATTERN = ('/\* Begin PBXContainerItemProxy section \*/\n'
                     '(?P<pbx_container_item_proxy_section>(.|\n)*)\n'
                     '/\* End PBXContainerItemProxy section \*/')
  
  FILE_REFERENCE_PATTERN = (
      '\t\t(?P<hash_code>[A-F0-9]*) /\* (?P<name>\S*) \*/ = {\n'
      '\t\t\tisa = (?P<class_name>\S*);\n'
      '\t\t\tcontainerPortal = (?P<container_portal>\S*) .*;\n'
      '\t\t\tproxyType = (?P<proxy_type>\S*);\n'
      '\t\t\tremoteGlobalIDString = (?P<remote_global_id_string>\S*);\n'
      '\t\t\tremoteInfo = (?P<remote_info>\S*);\n'
      '\t\t};')
  
  STRING_REPRESENTATION = (
      '/t/t%s /* %s */ = {\n'
      '/t/t/tisa = %s;\n'
      '/t/t/tcontainerPortal = %s /* Project object */;\n'
      '/t/t/tproxyType = %s;\n'
      '/t/t/tremoteGlobalIDString = %s;\n'
      '/t/t/tremoteInfo = %s;\n'
      '/t/t};\n')

  def __init__(self, hash_code, class_name, name, container_portal, proxy_type,
               remote_global_id_string, remote_info):
    """Initializes a PBXContainerItemProxy object
    
    Args:
      hash_code: str, The hashcode - unique ID of the object.
      class_name: str, The name of the class in Xcode (PBXContainerItemProxy).
      name: str, The name of the container item proxy.
      container_portal: str, The hashcode of the project object.
      proxy_type: str, The type of the proxy (number).
      remote_global_id_string: str, The global hashcode of the native target.
      remote_info: str, The name of the project.
    """
    self.hash_code = hash_code
    self.class_name = class_name
    self.name = name
    self.container_portal = container_portal
    self.proxy_type = proxy_type
    self.remote_global_id_string = remote_global_id_string
    self.remote_info = remote_info
    
  def __str__(self):
    """Generates the representation of the PBXContainerItemProxy object."""
    return PBXContainerItemProxy.STRING_REPRESENTATION % (
        self.hash_code, self.class_name, self.name, self.container_portal, 
        self.proxy_type, self.remote_global_id_string, self.remote_info)
  
  @staticmethod          
  def get_pbx_container_item_proxy(data):
    """Parses the PBXContainerItemProxy section inside the data.
    
    Args:
      data: str, The Xcode project file data.
    
    Returns:
      PBXContainerItemProxy, The container item proxy object.
    """
    pbx_container_item_proxy = None
    match = re.search(PBXContainerItemProxy.SECTION_PATTERN, data)
    if match:
      section = match.group('pbx_container_item_proxy_section')
      match = re.match(PBXContainerItemProxy.FILE_REFERENCE_PATTERN, section)
      if match:
        pbx_container_item_proxy = PBXContainerItemProxy(
            match.group('hash_code'), match.group('class_name'),
            match.group('name'), match.group('container_portal'),
            match.group('proxy_type'), match.group('remote_global_id_string'),
            match.group('remote_info'))
            
    return pbx_container_item_proxy   

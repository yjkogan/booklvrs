# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import commands
import glob
import json
import os
import re
import StringIO
import sys
import urllib2
import zipfile

import abstract_script


class ProjectConfig(abstract_script.AbstractScript):
  """Contains the project configurations.
  
  Also gathers all the information that the script is going to use. The
  reason for this is to be able to abort if some information is missing or 
  not correct before applying any changes to any files.
  """
  
  XCODE_PROJECT_FILE_EXTENSION = '.xcodeproj'

  # This is the location of the PBXProject file inside the xcodeproj folder.
  PBX_PROJECT_FILE_PATH = 'project.pbxproj'
  
  APP_ID_PATTERN = 'APP_ID = (?P<key>\w*)'

  DEVELOPMENT_KEY_PATTERN = 'DEV_KEY = (?P<key>\w*)'

  PRODUCTION_KEY_PATTERN = 'PROD_KEY = (?P<key>\w*)'

  ENTER_KEY_MESSAGE = 'Enter your Leanplum %s.'
  
  ENTER_KEY_TITLE = 'Leanplum %s'
  
  LEANPLUM_KEYS_MESSAGE = ('You can find your %s within Account > Apps on the '
                           'Leanplum dashboard.\n\n')

  SDK_VERSION_URL = ('http://www.leanplum.com'
                     '/api?appId=%s&clientKey=%s&'
                     'action=getSDKVersion&apiVersion=1.0.6'
                     '&client=ios')
  
  SDK_ZIP_URL = ('https://s3.amazonaws.com/leanplum_sdk/Leanplum-%s.zip')
  
  NUMBER_OF_LEVELS_TO_SEARCH = 2

  def __init__(self):
    self._get_root_path()
    self._get_keys()
    self._find_project_paths()
    self._find_important_files()
    self._find_source_files()
    match = re.search('Xcode ([a-zA-Z0-9.]+)',
                      os.popen('xcodebuild -version').readlines()[0])
    self.xcode_version = match.groups(0) if match else 0
    self.sdk_version = self._get_sdk_version(self.app_id,
                                             self.production_key)
    if not self.sdk_version:
      self._abort(
          self.COULD_NOT_RETRIEVE_THE_SDK_VERSION)
    self._get_sdk()
    
  def _get_root_path(self):
    """Finds the root dir of the script"""
    if os.path.dirname(sys.argv[0]):
      self.root_dir = os.path.dirname(sys.argv[0])
    else:
      self.root_dir = os.getcwd()
    os.chdir(self.root_dir)
    print(self.INSTALLER_DIRECTORY)
    
  def _find_project_paths(self):
    """Finds the name and path of the important project files and folders.
    
    Starts from the 3rd parent directory, because the script working directory 
    is inside the resource folder inside the script application bundle.
    """
    self.xcode_project_file_path = self._find_xcode_project(
        os.path.join(self.root_dir, '../../../'), 
        self.NUMBER_OF_LEVELS_TO_SEARCH)
  
    if self.xcode_project_file_path is None:
      self._abort(self.PROJECT_FILE_NOT_FOUND)
  
    self.pbx_project_file_path = os.path.join(self.xcode_project_file_path,
                                          self.PBX_PROJECT_FILE_PATH)
    
    print(self.PATH_TO_PROJECT_FILE % self.xcode_project_file_path)
    
    if not os.path.exists(self.pbx_project_file_path):
      self._abort(self.PBX_PROJECT_FILE_NOT_FOUND)
    self.project_path = os.path.dirname(self.xcode_project_file_path) 
      
    if self.project_path is None:
      self._abort(self.PROJECT_FOLDER_NOT_FOUND)
      
    print(self.PATH_TO_PROJECT % self.project_path)
      
    self.xcode_project_file_name = os.path.basename(
        self.xcode_project_file_path)
    
    self.main_group = self.xcode_project_file_name[:-len(
        self.XCODE_PROJECT_FILE_EXTENSION)]
    self.xcode_project_name = self.main_group
    
    if not os.path.exists(os.path.join(self.project_path, 
                                       self.main_group)):
      self.main_group = ''
    print(self.MAIN_PROJECT_GROUP)
    
  def _find_important_files(self):
    """Finds the name and path to the important files for the script.
    
    This includes main.m file, appDelegate.m file, prefix file.
    """
    main_m_path = self._find_file(self.project_path, 'main.m')
  
    if main_m_path is None:
      main_m_path = self._find_file(self.project_path, 'main.mm')
      if main_m_path is None:
        self._abort(self.MAIN_M_FILE_NOT_FOUND)
    print(self.MAIN_M_PATH % main_m_path)
      
    self._find_app_delegate_path(main_m_path)
    
    if self.app_delegate_path is None:
      self._abort(self.APP_DELEGATE_NOT_FOUND)
    
    if not self.app_delegate_name:
      self.app_delegate_name = os.path.splitext(os.path.basename(self.app_delegate_path))[0]
      
    print(self.APP_DELEGATE_PATH % self.app_delegate_path)
      
    self.prefix_file_path = self._find_file(self.project_path,
                                            self.xcode_project_name + 
                                            "-Prefix.pch")

    if self.prefix_file_path is None:
      self.prefix_file_path = self._find_file(self.project_path,
                                            self.xcode_project_name + 
                                            "_Prefix.pch")
      
    print(self.PREFIX_FILE_PATH % self.prefix_file_path)
  
    # We don't use the prefix file right now. Add again when we start using it.
    #if self.prefix_file_path is None:
      #self._abort(self.PREFIX_FILE_NOT_FOUND)

  def _find_source_files(self):
    self.hasFlurry = False
    self.hasGoogleAnalytics = False
    self.source_files = []
    for directory, _, files in os.walk(self.project_path):
      if directory.find('backup') != -1:
        continue
      if directory.find('LeanplumIOSSample') != -1:
        continue
      for current_file in files:
        if current_file.endswith(".m") or current_file.endswith(".mm"):
          self.source_files.append(os.path.join(directory, current_file))
        if current_file.find('Flurry') != -1:
          self.hasFlurry = True
        if current_file.find('GAI') != -1:
          self.hasGoogleAnalytics = True
    if self.hasFlurry:
      print(self.FLURRY_ANALYTICS)
    if self.hasGoogleAnalytics:
      print(self.GOOGLE_ANALYTICS)
    print(self.SOURCE_FILES)

  def _get_keys(self):
    """Gets the keys used by the scripts.
    
    This includes app_id, development_key and production_key.
    """
    keys_txt_data = ''
    leanplum_keys_txt_path = self._find_file(os.path.join(self.root_dir, '../../..'), 'keys.txt', is_suffix=True)
    if leanplum_keys_txt_path and os.path.exists(leanplum_keys_txt_path):
      with open(leanplum_keys_txt_path, 'r') as keys_file:
        keys_txt_data = keys_file.read()
    
    self.app_id = self._get_key(self.APP_ID_PATTERN, 'App ID', keys_txt_data)
    self.development_key = self._get_key(
        self.DEVELOPMENT_KEY_PATTERN, 'development key', keys_txt_data)
    self.production_key = self._get_key(
        self.PRODUCTION_KEY_PATTERN, 'production key', keys_txt_data)
    print(self.KEYS)
  
  def _get_key(self, key_line_pattern, key_type, keys_txt_data):
    """Gets the an app key either from the user or from the keys.txt file.
    
    Args:
      key_line_pattern: str, The key pattern to look for.
      key_type: str, The type of the key - App ID, development key or 
          production key.
      keys_txt_data: str, The data of the keys.txt file. It is empty string if 
          the file was not found or could not be read.
    
    Returns:
      str, The key.
    """
    input_message = self.ENTER_KEY_MESSAGE % key_type
    input_title = self.ENTER_KEY_TITLE % key_type
    reminder_message = self.LEANPLUM_KEYS_MESSAGE % key_type
    match = re.search(key_line_pattern, keys_txt_data)
    if match:
      return match.group('key')
    else:
      output = commands.getoutput(
          './CocoaDialog.app/Contents/MacOS/CocoaDialog standard-inputbox '
          '--title "%s" --informative-text "%s\n\n%s" --float'
          '--string-output' % (input_title, input_message, reminder_message))
      output_lines = output.split('\n')
      if len(output_lines) > 1 and (output_lines[0] == 'Ok' or 
                                    output_lines[0] == '1'):
        return output_lines[1]
      else:
        return ''
     
  def _get_sdk_version(self, app_id, client_key):
    """Gets the latest sdk version from the Leanplum server.
    
    Args:
      app_id: str, The app ID.
      client_key: str, The app development key.
    
    Returns:
      str, The latest sdk version.
    """
    sdk_version_url = self.SDK_VERSION_URL % (app_id, client_key)
    try:
      response = urllib2.urlopen(sdk_version_url)
      if response.code == 200:
        response_data = response.read()
        json_response = json.loads(response_data)
        return json_response['response'][0]['sdkVersion']
      return None
    except (urllib2.HTTPError, urllib2.URLError) as e:
      pass
    print(self.SDK_VERSION)
    
  def _get_sdk(self):
    """Downloads the latest sdk from the Leanplum server."""
    print(self.DOWNLOAD_SDK)
    sdk_url = self.SDK_ZIP_URL % self.sdk_version
    try:
      response = urllib2.urlopen(sdk_url)
      if response.code == 200:
        zip_data = response.read()
        zip_file = zipfile.ZipFile(StringIO.StringIO(zip_data))
        zip_file.extractall()
      return None
    except (urllib2.HTTPError, urllib2.URLError) as e:
      pass
    print(self.DOWNLOAD_SDK_FINISHED)
  
  def _find_file(self, directory_path, file_name, is_suffix = False):
    """Finds the file inside the directory.
    
    Args:
      directory: str, The directory to look in.
      file_name: str, The name of the file to look for.
      
    Returns:
      str or None, The file path.
    """
    for directory, _, files in os.walk(directory_path):
      if directory.find('backup') != -1:
        continue
      if directory.find(os.path.join('Contents', 'Resources', 'LeanplumIOSSample')) != -1:
        continue
      for current_file in files:
        if current_file == file_name:
          file_path = os.path.join(directory, current_file)
          return file_path
        if is_suffix and current_file.endswith(file_name):
          file_path = os.path.join(directory, current_file)
          return file_path
    return None  

  def _find_app_delegate_path(self, main_m_path):
    """Finds the AppDelegate file name.
    
    Args:
      main_m_path: str, The path to the main.m file.
      
    """
    self.app_delegate_name = self._find_app_delegate_file_name(main_m_path)
    self.app_delegate_file_name = self.app_delegate_name + '.m'
    
    self.app_delegate_path = self._find_file(self.project_path,
                                             self.app_delegate_file_name)
  
    if self.app_delegate_path is None:
      self.app_delegate_file_name = self.app_delegate_name + '.mm'
      self.app_delegate_path = self._find_file(self.project_path,
                                               self.app_delegate_file_name)

    if self.app_delegate_path is None:
      self.app_delegate_path = self._find_file(self.project_path, 'AppDelegate.m', is_suffix=True)

    if self.app_delegate_path is None:
      self.app_delegate_path = self._find_file(self.project_path, 'AppDelegate.mm', is_suffix=True)

  
  def _find_app_delegate_file_name(self, main_m_path):
    """Finds the AppDelegate file name by looking into the main.m file.
    
    Args:
      main_m_path: str, The path to the main.m file.
      
    Returns:
      str, The AppDelegate file name.
    """
    app_delegate_file_name = ''
  
    if os.path.exists(main_m_path):
      with open(main_m_path, 'r') as main_m_file:
        main_file_content = main_m_file.read()
        app_delegate_code_search = re.search('\(\[.* class\]\)',
                                             main_file_content)
        if app_delegate_code_search:
          app_delegate_file_name = app_delegate_code_search.group(0)[
              2:-2].split(' ')[0]
    else:
      self._abort(self.MAIN_M_FILE_NOT_FOUND)
  
    return app_delegate_file_name
  
  def _find_xcode_project(self, directory, number_of_levels_to_search):
    """Finds the Xcode project file path recursively going in parent directory.
    
    Args:
      directory: str, The directory to look in.
      number_of_levels_to_search: int, How many parent levels to look in.
      
    Returns:
      str or None, The Xcode project file path.
    """
    if number_of_levels_to_search <= 0:
      return None
    else:
      project_file_paths = glob.glob(directory + '*.xcodeproj')
          
      if not project_file_paths:
        return self._find_xcode_project(os.path.join(directory, '../'),
                                        number_of_levels_to_search - 1)
      elif len(project_file_paths) == 1:
        project_file_path = os.path.abspath(project_file_paths[0])
        if self.NUMBER_OF_LEVELS_TO_SEARCH != number_of_levels_to_search:
          self._confirm_to_continue(
              ('Is this your xcode project file?\n%s') % project_file_path)
        return project_file_path
      else:
        self._abort(self.MULTIPLE_PROJECT_FILES_FOUND)
        return None

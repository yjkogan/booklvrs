# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import commands
import json
import sys
import smtplib
import urllib
import urllib2


class AbstractScript(object):
  """Handles the execution and termination of the script."""

  ABORT_INPUT_MESSAGE = ('The script is unable to continue!\n  For further'
                         ' assistance please contact support@leanplum.com\n\n')

  ABORT_MESSAGE = ('  %s\n  The installation has been canceled.\n  Please make '
                   'sure that the installer is in a folder along side your xcode '
                   'project file.\n  For further assistance please contact '
                   'support@leanplum.com\n\n'
                   'You can also setup the SDK manually by going to the '
                   'Setup page on our website and clicking "I want to install the '
                   'Leanplum SDK manually" next to the download link.')

  PROJECT_FILE_NOT_FOUND = ("  The script couldn't locate your project file."
                            "\n\n")
  
  PBX_PROJECT_FILE_NOT_FOUND = ("  The script couldn't locate your PBXProject "
                                "file.\n\n")

  PROJECT_FOLDER_NOT_FOUND = ("  The script couldn't locate your project "
                              "folder.\n\n")

  MAIN_M_FILE_NOT_FOUND = ("  The script couldn't locate your main.m file.\n\n")

  APP_DELEGATE_NOT_FOUND = ("  The script couldn't locate your AppDelegate "
                            "file.\n\n")

  PREFIX_FILE_NOT_FOUND = ("  The script couldn't locate your Prefix.pch "
                           "file.\n\n")
  
  MULTIPLE_PROJECT_FILES_FOUND = ('  The project contains multiple xcode '
                                  'project files.\n\n')
  
  COULD_NOT_RETRIEVE_THE_SDK_VERSION = ("  The script couldn't retrieve the "
                                        "sdk version from the server.\n\n")
  
  FILE_NOT_FOUND_IN_THE_SCRIPT_FOLDER = ('  %s not found! There was a problem '
                                         'downloading the SDK from the server.\n\n')
  
  SCRIPT_INTRODUCTION_MESSAGE = ('\nThis script will add the Leanplum library '
                                 'and code inside your Xcode project file, '
                                 'appDelegate file, and Prefix file.\n\nDo you'
                                 ' want to continue the installation?\n')
  
  INSTALLER_DIRECTORY = ('  Installer directory found.\n')
  
  PATH_TO_PROJECT_FILE = ('  The project file found:\n    %s\n')
  
  PATH_TO_PROJECT = ('  Project directory found:\n    %s\n')
  
  MAIN_PROJECT_GROUP = ('  Main project group found.\n')
  
  MAIN_M_PATH = ('  main file found:\n    %s\n')
  
  APP_DELEGATE_PATH = ('  AppDelegate file found:\n    %s\n')
  
  PREFIX_FILE_PATH = ('  Prefix file found:\n    %s\n')
  
  SOURCE_FILES = ('  Source files found.\n')
  
  GOOGLE_ANALYTICS = ('  Google analytics found.\n')
  
  FLURRY_ANALYTICS = ('  Flurry analytics found.\n')
  
  KEYS = ('  Keys set.\n')
  
  SDK_VERSION = ('  The latest version of the SDK retrieved from the server.\n')
  
  DOWNLOAD_SDK = ('  Downloading the SDK.\n')

  DOWNLOAD_SDK_FINISHED = ('  The SDK has been downloaded.\n')

  PROJECT_CONFIGURATION_STARTED = ('  Building project configuration started.\n')

  PROJECT_CONFIGURATION_FINISHED = ('  Building project configuration finished.\n')

  BACKUP_FINISHED = ('  Backup created.\n')

  SDK_FILES_INSTALLED = ('  Leanplum SDK files installed.\n')
  
  FLURRY_CALLS = ('  Leanplum calls for Flurry Analytics added.')

  GOOGLE_ANALYTICS_CALLS = ('  Leanplum calls for Google Analytics added.')

  REBUILD_PATHS = ('  Rebuild project paths.')
  
  LOG_URL = ('http://www.leanplum.com/api?')

  def _abort(self, abort_reason='', project_config = None):
    print(self.ABORT_MESSAGE % abort_reason)
    self._send_log('Installer abort!', abort_reason, project_config)
    sys.exit(1)

  def _confirm_to_continue(self, message):
    user_response = ''
    while user_response not in ('Ok', 'Cancel'):
      output = commands.getoutput(
          './CocoaDialog.app/Contents/MacOS/CocoaDialog ok-msgbox'
          ' --title "Leanplum Installer" --text "Confirm installation"'
          ' --informative-text "%s" --string-output --float' % message)
      output_lines = output.split('\n')
      if len(output_lines) > 0:
        user_response = output_lines[0]
      else:
        user_response = 'Cancel'
      if user_response == 'Yes':
        return
      if user_response == 'Cancel':
        self._abort(self.ABORT_INPUT_MESSAGE)
        
  def _send_log(self, subject, message, project_config):
    app_id = ''
    if project_config:
      app_id = project_config.app_id
    elif hasattr(self, 'app_id'):
      app_id = self.app_id
    production_key = ''
    if project_config:
      production_key = project_config.production_key
    elif hasattr(self, 'production_key'):
      production_key = self.production_key
    post_values = {
        'appId': (app_id if app_id else ''),
        'clientKey': (production_key if production_key else ''),
        'action': 'log',
        'apiVersion': '1.0.6',
        'client': 'ios',
        'subject': subject,
        'log_message': message }
    post_data = urllib.urlencode(post_values)
    log_url = self.LOG_URL
    try:
      request = urllib2.Request(log_url, post_data)
      response = urllib2.urlopen(request)
      if response.code == 200:
        response_data = response.read()
        json_response = json.loads(response_data)
    except (urllib2.HTTPError, urllib2.URLError) as e:
      pass
    pass

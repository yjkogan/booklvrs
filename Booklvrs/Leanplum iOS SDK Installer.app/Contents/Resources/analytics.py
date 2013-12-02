# All rights reserved. Leanplum. 2013.
# Author: Atanas Dobrev (dobrev@leanplum.com)

import re


class AbstractAnalytics(object):
  """Contains the commong methods for all the analytics classes"""

  IMPORTS_PATTERN = '(?P<imports_group>(#import\s*\S*\s*\n)+)'

  @staticmethod
  def _add_import_statement(library, source_code):
    """Adds the Leanplum import statements to an activity.
      
    Args:
      library: str, Which library does the activity extend.
      source_code: str, The activity source code.
      
    Returns:
      source_code: str, The modified source code.
    """
    if library and not re.search('#import\s+"%s"' % library, source_code): 
      import_match = re.search(AbstractAnalytics.IMPORTS_PATTERN, 
                               source_code)
      if import_match:
        source_code = re.sub(import_match.group('imports_group'), 
            import_match.group('imports_group') + '#import "' + library + '"\n\n', 
            source_code)
    return source_code


class GoogleAnalytics(AbstractAnalytics):
  """Handles the execution and termination of Google analytics object."""

  GOOGLE_TRACK_PATTERN = ('((?P<white_space>[^\S\n]*)\[\s*\S*\s+'
                          'send\s*:\s*(?P<dictionary_call>[^;]*)\s*\]\s*;)')

  LEANPLUM_TRACK_CALL = '%s\n%s[Leanplum gaTrack:%s];'

  @staticmethod
  def run(source_file_paths):
    for source_file_path in source_file_paths:
      source_file_data = ''
      replaced_calls = {}
      with open(source_file_path, 'r') as source_file:
        source_file_data = source_file.read()
        if not re.search('#import\s+"Leanplum.h"', source_file_data):
          match = re.findall(GoogleAnalytics.GOOGLE_TRACK_PATTERN, 
                           source_file_data)
          should_add_leanplum_library = False
          for google_analytics_call in match:
            if not replaced_calls.get(google_analytics_call[0], False):
              source_file_data = re.sub(
                  re.escape(google_analytics_call[0]), 
                  GoogleAnalytics.LEANPLUM_TRACK_CALL
                  % (google_analytics_call[0], google_analytics_call[1], 
                     google_analytics_call[2]), 
                  source_file_data)
              replaced_calls[google_analytics_call[0]] = True
              should_add_leanplum_library = True
          if should_add_leanplum_library:
            source_file_data = GoogleAnalytics._add_import_statement('Leanplum.h', 
                                                                     source_file_data)
      with open(source_file_path, 'w') as source_file:
        source_file.write(source_file_data)

class FlurryAnalytics(AbstractAnalytics):
  """Handles the execution and termination of Flurry analytics object."""

  FLURRY_EVENT = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                  'logEvent\s*:\s*(?P<event>[^;]*)\s*\]\s*;)')

  LEANPLUM_EVENT = '%s\n%s[Leanplum track:%s];'

  FLURRY_EVENT_PARAMS = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                         'logEvent\s*:\s*(?P<event>[^;]*)\s*'
                         'withParameters\s*:\s*(?P<params>[^;]*)\s*\]\s*;)')

  LEANPLUM_EVENT_PARAMS = '%s\n%s[Leanplum track:%s withParameters:%s];'

  FLURRY_ERROR_MESSAGE_EXCEPTION = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                                    'logError\s*:\s*(?P<error>[^;]*)\s*'
                                    'message\s*:\s*(?P<message>[^;]*)\s*'
                                    'exception\s*:\s*(?P<exception>[^;]*)\s*\]\s*;)')

  LEANPLUM_ERROR_MESSAGE_EXCEPTION = ('%s\n%s[Leanplum track:[%s stringByAppendingString:@"_error"]'
                                      ' withParameters: @{@"message": %s, @"exception": %s ? %s : [NSNull null]}];')

  FLURRY_ERROR_MESSAGE_ERROR = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                                'logError\s*:\s*(?P<error>[^;]*)\s*'
                                'message\s*:\s*(?P<message>[^;]*)\s*'
                                'error\s*:\s*(?P<ns_error>[^;]*)\s*\]\s*;)')

  LEANPLUM_ERROR_MESSAGE_ERROR = ('%s\n%s[Leanplum track:[%s stringByAppendingString:@"_error"] '
                                  'withParameters:@{@"message":%s, @"error": %s ? %s : [NSNull null]}];')

  FLURRY_EVENT_TIMED = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                        'logEvent\s*:\s*(?P<event>[^;]*)\s*'
                        'timed\s*:\s*(?P<timed>[^;]*)\s*\]\s*;)')

  LEANPLUM_EVENT_TIMED = ('%s\n%sif (%s) {\n%s'
                          '    [Leanplum track:[%s '
                          'stringByAppendingString:@"_begin"]];\n%s} else {\n%s'
                          '    [Leanplum track:%s];\n%s}')

  FLURRY_EVENT_PARAMS_TIMED = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                               'logEvent\s*:\s*(?P<error>[^;]*)\s*'
                               'withParameters\s*:\s*(?P<params>[^;]*)\s*'
                               'timed\s*:\s*(?P<timed>[^;]*)\s*\]\s*;)')

  LEANPLUM_EVENT_PARAMS_TIMED = ('%s\n%sif (%s) {\n%s'
                                 '    [Leanplum track:[%s stringByAppendingString:@"_begin"] '
                                 'withParameters:%s];\n%s} else {\n%s'
                                 '    [Leanplum track:%s withParameters:%s];\n%s}')

  FLURRY_END_EVENT_PARAMS = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                             'endTimedEvent\s*:\s*(?P<event>[^;]*)\s*'
                             'withParameters\s*:\s*(?P<params>[^;]*)\s*\]\s*;)')

  LEANPLUM_END_EVENT_PARAMS = ('%s\n%s[Leanplum track:[%s '
                               'stringByAppendingString:@"_end"] withParameters:%s];')

  FLURRY_LOG_PAGE_VIEW = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                          'logPageView\s*\]\s*;)')

  LEANPLUM_LOG_PAGE_VIEW = '%s\n%s[Leanplum track:@"PAGE_VIEW"];'

  FLURRY_USER_ID = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                    'setUserID\s*:\s*(?P<user_id>[^;]*)\s*\]\s*;)')

  LEANPLUM_USER_ID = '%s\n%s[Leanplum setUserId:%s];'

  FLURRY_AGE = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                'setAge\s*:\s*(?P<age>[^;]*)\s*\]\s*;)')

  LEANPLUM_AGE = '%s\n%s[Leanplum setUserAttributes:@{@"age":[NSNumber numberWithInt:%s]}];'

  FLURRY_GENDER = ('((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
                   'setGender\s*:\s*(?P<gender>[^;]*)\s*\]\s*;)')

  LEANPLUM_GENDER = '%s\n%s[Leanplum setUserAttributes:@{@"gender":%s}];'

  FLURRY_LOCATION = (
      '((?P<white_space>[^\S\n]*)\[\s*Flurry\s+'
      'setLatitude\s*:\s*(?P<latitude>[^;]*)\s*'
      'longitude\s*:\s*(?P<longitude>[^;]*)\s*'
      'horizontalAccuracy\s*:\s*(?P<horizontal_accuracy>[^;]*)\s*'
      'verticalAccuracy\s*:\s*(?P<vertical_accuracy>[^;]*)\s*\]\s*;)')

  LEANPLUM_LOCATION = ('%s\n%s[Leanplum setUserAttributes:'
                       '@{@"latitude":[NSNumber numberWithDouble:%s], '
                       '@"longitude":[NSNumber numberWithDouble:%s], '
                       '@"horizontal_accuracy":[NSNumber numberWithDouble:%s], '
                       '@"vertical_accuracy":[NSNumber numberWithDouble:%s]}];')

  @staticmethod
  def run(source_file_paths):
    for source_file_path in source_file_paths:
      calls = [
          (FlurryAnalytics.FLURRY_EVENT_PARAMS_TIMED, 
           FlurryAnalytics.LEANPLUM_EVENT_PARAMS_TIMED),
          (FlurryAnalytics.FLURRY_EVENT_TIMED, FlurryAnalytics.LEANPLUM_EVENT_TIMED),
          (FlurryAnalytics.FLURRY_EVENT, FlurryAnalytics.LEANPLUM_EVENT), 
          (FlurryAnalytics.FLURRY_EVENT_PARAMS, FlurryAnalytics.LEANPLUM_EVENT_PARAMS), 
          (FlurryAnalytics.FLURRY_ERROR_MESSAGE_EXCEPTION, 
           FlurryAnalytics.LEANPLUM_ERROR_MESSAGE_EXCEPTION), 
          (FlurryAnalytics.FLURRY_ERROR_MESSAGE_ERROR, 
           FlurryAnalytics.LEANPLUM_ERROR_MESSAGE_ERROR), 
          (FlurryAnalytics.FLURRY_END_EVENT_PARAMS, 
           FlurryAnalytics.LEANPLUM_END_EVENT_PARAMS), 
          (FlurryAnalytics.FLURRY_LOG_PAGE_VIEW, FlurryAnalytics.LEANPLUM_LOG_PAGE_VIEW), 
          (FlurryAnalytics.FLURRY_USER_ID, FlurryAnalytics.LEANPLUM_USER_ID), 
          (FlurryAnalytics.FLURRY_AGE, FlurryAnalytics.LEANPLUM_AGE), 
          (FlurryAnalytics.FLURRY_GENDER, FlurryAnalytics.LEANPLUM_GENDER), 
          (FlurryAnalytics.FLURRY_LOCATION, FlurryAnalytics.LEANPLUM_LOCATION)]
      source_file_data = ''
      replaced_calls = {}
      with open(source_file_path, 'r') as source_file:
        source_file_data = source_file.read()
        if not re.search('#import\s+"Leanplum.h"', source_file_data):
          should_add_leanplum_library = False
          for (call_pattern, call_replace_string) in calls:
            match = re.findall(call_pattern, source_file_data)
            for call in match:
              if not replaced_calls.get(call[0], False):
                # TODO(n4sk0) Format the output when ever you have time.
                if call_pattern == FlurryAnalytics.FLURRY_EVENT_TIMED:
                  source_file_data = re.sub(
                      re.escape(call[0]), 
                      call_replace_string % (call[0], call[1], call[3], 
                          call[1], call[2], call[1], call[1], call[2], call[1]), 
                      source_file_data)
                elif call_pattern == FlurryAnalytics.FLURRY_EVENT_PARAMS_TIMED:
                  source_file_data = re.sub(
                      re.escape(call[0]), 
                      call_replace_string % (call[0], call[1], call[4], call[1], 
                          call[2], call[3], call[1], call[1], call[2], call[3], call[1]), 
                      source_file_data)
                elif (call_pattern == FlurryAnalytics.FLURRY_ERROR_MESSAGE_EXCEPTION or
                      call_pattern == FlurryAnalytics.FLURRY_ERROR_MESSAGE_ERROR):
                  source_file_data = re.sub(
                      re.escape(call[0]), 
                      call_replace_string % (call[0], call[1], call[2], call[3], 
                          call[4], call[4]), 
                      source_file_data)  
                else:
                  source_file_data = re.sub(
                      re.escape(call[0]), 
                      call_replace_string % call, 
                      source_file_data)
                replaced_calls[call[0]] = True
                should_add_leanplum_library = True
          if should_add_leanplum_library:
            source_file_data = FlurryAnalytics._add_import_statement('Leanplum.h', source_file_data)
      with open(source_file_path, 'w') as source_file:
        source_file.write(source_file_data)

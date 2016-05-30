# ADAppRater-iOS Release Notes

##### Version 1.0.9
_Released on May XX, 2016_
* Issue #18: Add option to re-prompt users to rate the app after a certain period, by invalidating their previous response
* Issue #20: Crashes on first version when setting promptForNewVersionIfUserRated to `YES`
* Improve documentation
* Improve unit testing to cover missing scenarios

##### Version 1.0.8
_Released on March 31, 2016_
* PR #17: Add a Russian translation for default texts

##### Version 1.0.7
_Released on March 30, 2016_
* Issue #12: Add a localization bundle to component

##### Version 1.0.6
_Merged into 1.0.7_
* New API: `[ADAppRater appRaterVersion]`
* iOS 7: Fix bug of broken flow
* Code refactor

##### Version 1.0.5
_Released on March 22, 2016_
* PR #15: Handle case where the view controller has no navigation controller

##### Version 1.0.4
_Released on February 26, 2016_
* Request: Do not reset event history if not supposed to ask again every version
* ATS: Use HTTPS for querying the App Store

##### Version 1.0.3
_Released on September 22, 2015_
* Request: Never show more then once per X days
  * Added `limitPromptFrequency` property to AppRater configuration, to define number of days
  * Added `userLastPromptedToRate` property to AppRater to return last time user was prompted
* Replaced `currentVersionLastReminded` property with `userLastRemindedToRate`.
* Reminder is no longer related to specific version.
  * Before: If a user asks to be reminded, but during the reminder period - the version was updated and usage reset, user would not be prompted again until he re-reached minimum usage.
  * Now: If a user asks to be reminded, but during the reminder period - the version was updated and usage reset, user will be reminded anyway, disregarding minimum usage.

##### Version 1.0.2
_Released on September 10, 2015_
* Fixed bug related to localizing strings

##### Version 1.0.1
_Released on August 31, 2015_
* Add Travis-CI
* Nicer Cocoa pod Description

##### Version 1.0.0
_Released on August 23, 2015_
* Initial release.

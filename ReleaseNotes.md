# ADAppRater-iOS Release Notes

##### Version 1.0.6
* New API: `[ADAppRater appRaterVersion]`
* iOS 7: Fix bug of broken flow
* Code refactor

##### Version 1.0.5
* PR #15: Handle case where the view controller has no navigation controller

##### Version 1.0.4
* Request: Do not reset event history if not supposed to ask again every version
* ATS: Use HTTPS for querying the App Store

##### Version 1.0.3
* Request: Never show more then once per X days
  * Added `limitPromptFrequency` property to AppRater configuration, to define number of days
  * Added `userLastPromptedToRate` property to AppRater to return last time user was prompted
* Replaced `currentVersionLastReminded` property with `userLastRemindedToRate`.
* Reminder is no longer related to specific version.
  * Before: If a user asks to be remined, but during the reminder period - the version was updated and usage reset, user would not be prompted again until he re-reached minimum usage.
  * Now: If a user asks to be remined, but during the reminder period - the version was updated and usage reset, user will be reminded anyway, disregarding minimum usage.

##### Version 1.0.2
* Fixed bug related to localising strings

##### Version 1.0.1
* Add Travis-CI
* Nicer Cocoapod Description

##### Version 1.0.0
* Initial release.

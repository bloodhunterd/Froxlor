# Changelog

All notable changes to this project will be documented in this file.

## <a name="v1-1-0"></a> [1.1.0](https://github.com/bloodhunterd/froxlor-docker/releases/tag/1.1.0) - 05.11.2020

* Another possible fix to prevent failing PHP services on the first start up added
* Added BIND as DNS service

## <a name="v1-0-0"></a> [1.0.0](https://github.com/bloodhunterd/froxlor-docker/releases/tag/1.0.0) - 11.08.2020

* Unneeded NSCD removed to increase performance
* Support now 3 PHP versions (currently 7.2, 7.3 and 7.4)
* MariaDB upgraded to major version 10.5
* Delay between process startup added to prevent first startup bug.
* Prevent multiple locale generation at start up. All locales are now available by default.
* Froxlor code excluded from image, since it must be setup individually.
* License changed from the Unlicense to MIT

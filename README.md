# Migrator

[![CI Status](http://img.shields.io/travis/SAKAI, Atsushi/Migrator.svg?style=flat)](https://travis-ci.org/SAKAI, Atsushi/Migrator)
[![Version](https://img.shields.io/cocoapods/v/Migrator.svg?style=flat)](http://cocoapods.org/pods/Migrator)
[![License](https://img.shields.io/cocoapods/l/Migrator.svg?style=flat)](http://cocoapods.org/pods/Migrator)
[![Platform](https://img.shields.io/cocoapods/p/Migrator.svg?style=flat)](http://cocoapods.org/pods/Migrator)

- ```Migrator``` is a library for performing the migration of the data when the iOS app has been upgraded.
- This library has implemented by Swift Language and inspired by [MFMigrationManager](https://github.com/fortinmike/MFMigrationManager).

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.
And please read my test code, you can understand the more specific usage.

### Basic

```swift
// Migrator Snippets
let migrator: Migrator = Migrator()
migrator.setInitialVersion("1.0.0") // Starting point you want to save the migration history
migrator.registerHandler("1.0.1") { () -> Void in
    print("[Migrator] Migration to v1.0.0....")
}
migrator.migrate()
```

### Optional

#### Delegate Methods

You can implement delegate methods to get migration results.

```swift
let migrator: Migrator = Migrator()
migrator.delegate = self

func didSucceededMigration(migratedVersion: String) {
    print("[Migrator] Did Succeeded Migration to version \(migratedVersion)!!")
}

func didFailedMigration(migratedVersion: String) {
    print("[Migrator] Did Failed Migration to version \(migratedVersion)!!")
}

func didCompletedAllMigration() {
    print("[Migrator] Completed Migrations!!")
}
```

## Installation

Migrator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Migrator"
```

## Author

SAKAI, Atsushi, sakai.atsushi@gmail.com

## License

Migrator is available under the MIT license. See the LICENSE file for more info.

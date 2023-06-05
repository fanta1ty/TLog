![Logo](https://github.com/fanta1ty/TLog/blob/master/Logo/Logo.png)

# TLog
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-brightgreen)](https://developer.apple.com/swift/)
[![Version](https://img.shields.io/cocoapods/v/TLog.svg?style=flat)](https://cocoapods.org/pods/TLog)
[![License](https://img.shields.io/cocoapods/l/TLog.svg?style=flat)](https://cocoapods.org/pods/TLog)
[![Platform](https://img.shields.io/cocoapods/p/TLog.svg?style=flat)](https://cocoapods.org/pods/TLog)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 12+
- Swift 5

## Installation

### Cocoapods
`TLog` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TLog'
```

### Swift Package
`TLog` is designed for Swift 5. To depend on the logging API package, you need to declare your dependency in your `Package.swift`

```swift
.package(url: "https://github.com/fanta1ty/TLog.git", brand: "master"),
```

## Usage
```swift
import TLog
```

- For Debug Logging:
```swift
TLog.debug("Debug !!!")
```
![Debug](https://github.com/fanta1ty/TLog/blob/master/Screenshots/Debug.png)

- For Error Logging:
```swift
TLog.error("Error !!!")
```
![Error](https://github.com/fanta1ty/TLog/blob/master/Screenshots/Error.png)

- For Info Logging:
```swift
TLog.info("Info !!!")
```
![Info](https://github.com/fanta1ty/TLog/blob/master/Screenshots/Info.png)

- For Server Logging:
```swift
TLog.server("Server !!!")
```
![Server](https://github.com/fanta1ty/TLog/blob/master/Screenshots/Server.png)

- For Verbose Logging:
```swift
TLog.verbose("Verbose !!!")
```
![Verbose](https://github.com/fanta1ty/TLog/blob/master/Screenshots/Verbose.png)

- For Warning Logging:
```swift
TLog.warning("Warning !!!")
```
![Warning](https://github.com/fanta1ty/TLog/blob/master/Screenshots/Warning.png)

- Enable/Disable `TLog`:
```swift
TLog.isLoggingEnabled = true/false
```        

## Author

fanta1ty, thinhnguyen12389@gmail.com

## License

TLog is available under the MIT license. See the LICENSE file for more info.

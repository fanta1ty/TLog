Pod::Spec.new do |s|
  s.name             = 'TLog'
  s.version          = '2.0.0'
  s.summary          = 'TLog can be used to debug and monitor the performance of applications written in Swift.'
  s.description      = 'TLog is a powerful, lightweight, and easy-to-use logging library for Swift applications. It provides multiple output destinations, customizable formatting, and enterprise-grade features while maintaining simplicity and performance.'
  s.homepage         = 'https://github.com/fanta1ty/TLog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fanta1ty' => 'thinhnguyen12389@gmail.com' }
  s.source           = { :git => 'https://github.com/fanta1ty/TLog.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/TLog/**/*'
  s.swift_version = '5.0'
end

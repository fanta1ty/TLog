Pod::Spec.new do |s|
  s.name             = 'TLog'
  s.version          = '1.0.2'
  s.summary          = 'TLog can be used to debug and monitor the performance of applications written in Swift.'
  s.description      = 'TLog is a Swift library that provides a simple and flexible way to log messages and events in your application. You can use TLog to track errors, warnings, debug information and more. TLog also allows you to configure the log level, format, and filter for each destination separately. With TLog, you can easily debug and monitor your Swift applications in any environment.'
  s.homepage         = 'https://github.com/fanta1ty/TLog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fanta1ty' => 'thinhnguyen12389@gmail.com' }
  s.source           = { :git => 'https://github.com/fanta1ty/TLog.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/TLog/**/*'
  s.swift_version = '5.0'
end

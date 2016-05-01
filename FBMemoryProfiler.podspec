#
#  Be sure to run `pod spec lint FBMemoryProfiler.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "FBMemoryProfiler"
  s.version      = "0.1.3"
  s.summary      = "iOS tool that helps with profiling iOS Memory usage"
  s.homepage     = "https://github.com/facebook/FBMemoryProfiler"
  s.license      = "BSD"
  s.author       = { "Grzegorz Pstrucha" => "gricha@fb.com" }
  s.platform     = :ios, "7.0"
  s.source       = {
    :git => "https://github.com/facebook/FBMemoryProfiler.git",
    :tag => "0.1.3"
  }
  s.source_files  = "FBMemoryProfiler", "FBMemoryProfiler/**/*.{h,m,mm,c}"

  files = Pathname.glob("FBMemoryProfiler/**/*.{m,mm}")
  files = files.map {|file| file.to_path}
  s.requires_arc = files

  s.dependency 'FBRetainCycleDetector', '~> 0.1'
  s.dependency 'FBAllocationTracker', '~> 0.1'
  
  s.framework = "Foundation", "CoreGraphics", "UIKit"
  s.library = 'c++'
end

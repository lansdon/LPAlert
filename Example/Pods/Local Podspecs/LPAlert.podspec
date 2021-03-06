Pod::Spec.new do |s|
  s.name             = "LPAlert"
  s.version          = "0.1.2"
  s.summary          = "A customizable alert class for IOS"
  s.description      = <<-DESC
                       - Add a title (optional)
					   - Add a subtitle (optional)
					   - Add any number of body labels (each style as you like)
					   - Add any number of buttons (each style as you like) 
					   * Note must be at least 1 button to close the alert!
					   - Control background and font colors for each label.
					   - Add blocks to buttons for custom actions
					   - Layout buttons side by side, or stacked.
                       DESC
  s.homepage         = "https://github.com/lansdon/LPAlert"
  s.license          = 'MIT'
  s.author           = { "Lansdon Page" => "lansdon.dev@gmail.com" }
  s.source           = { :git => "https://github.com/lansdon/LPAlert.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'ACPButton'
end

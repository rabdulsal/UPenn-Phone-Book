# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Phone Book' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  def shared_pods
    pod ‘Alamofire’
  end

  target 'Phone Book' do
      shared_pods
  end

  target 'Phone BookTests' do
    inherit! :search_paths
    shared_pods
  end

  target 'Phone BookUITests' do
    inherit! :search_paths
    shared_pods
  end

end

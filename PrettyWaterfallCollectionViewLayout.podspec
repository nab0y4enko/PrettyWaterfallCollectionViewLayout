Pod::Spec.new do |s|
    s.name              = "PrettyWaterfallCollectionViewLayout"
    s.module_name       = "PrettyWaterfallCollectionViewLayout"
    s.version           = "0.1.0"
    s.summary           = "A pretty vertical layout."
    s.description       = "A pretty vertical layout with the ability to configure the number of column, based on Swift."
    s.homepage          = "https://github.com/nab0y4enko/PrettyWaterfallCollectionViewLayout"
    s.license           = 'MIT'
    s.author            = { "Oleksii Naboichenko" => "nab0y4enko@gmail.com" }
    s.social_media_url  = "https://twitter.com/nab0y4enko"
   
    s.source            = { :git => "https://github.com/nab0y4enko/PrettyWaterfallCollectionViewLayout.git", :tag => "#{s.version}" }
    s.source_files      = "Sources/**/*.swift"

    s.frameworks        = "UIKit"

    s.ios.deployment_target = '10.0'

    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end

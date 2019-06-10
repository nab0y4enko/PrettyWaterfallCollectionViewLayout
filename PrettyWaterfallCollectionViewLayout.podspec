Pod::Spec.new do |spec|
    spec.name              = "PrettyWaterfallCollectionViewLayout"
    spec.module_name       = "PrettyWaterfallCollectionViewLayout"
    spec.version           = "0.4.0"
    spec.summary           = "A pretty layouts."
    spec.description       = "A pretty layouts with the ability to configure the number of column/row, based on Swift."
    spec.homepage          = "https://github.com/nab0y4enko/PrettyWaterfallCollectionViewLayout"
    spec.license           = 'MIT'
    spec.author            = { "Oleksii Naboichenko" => "nab0y4enko@gmail.com" }
    spec.social_media_url  = "https://twitter.com/nab0y4enko"
   
    spec.source            = { :git => "https://github.com/nab0y4enko/PrettyWaterfallCollectionViewLayout.git", :tag => "#{spec.version}" }

    spec.frameworks        = "UIKit"

    spec.ios.deployment_target = '10.0'

    spec.swift_versions = ['4.0', '4.2', '5.0']

    spec.default_subspecs = 'VerticalWaterfall', 'HorizontalWaterfall'

    spec.subspec 'VerticalWaterfall' do |subspec|
        subspec.ios.frameworks = 'UIKit'
        subspec.source_files = 'Sources/VerticalWaterfall/*'
    end

    spec.subspec 'HorizontalWaterfall' do |subspec|
        subspec.source_files = 'Sources/HorizontalWaterfall/*'
    end

end

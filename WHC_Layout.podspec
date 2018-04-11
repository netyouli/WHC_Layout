`echo "4.0" > .swift-version`
Pod::Spec.new do |s|
  s.name         = "WHC_Layout"
  s.version      = "1.1.5.3"
  s.summary      = "Swift4.+ Service to update constraints, convenient and quick dynamic UI layout，服务于更新约束方便快捷动态UI构建的自动布局库，支持Cell高度自动，view高宽自动"

  s.homepage     = "https://github.com/netyouli/WHC_Layout"

  s.license      = "MIT"

  s.author             = { "吴海超(WHC)" => "712641411@qq.com" }

  s.source       = { :git => "https://github.com/netyouli/WHC_Layout.git", :tag => "1.1.5.3"}

  s.source_files  = "WHC_LayoutKit/*.{swift}"
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true


end

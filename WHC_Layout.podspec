Pod::Spec.new do |s|
  s.name         = "WHC_Layout"
  s.version      = "1.0.0"
  s.summary      = "Swift Service to update constraints, convenient and quick dynamic UI layout，服务于更新约束方便快捷动态UI构建的自动布局库，支持Cell高度自动，view高宽自动"

  s.homepage     = "https://github.com/netyouli/WHC_Layout"

  s.license      = "MIT"

  s.author             = { "吴海超(WHC)" => "712641411@qq.com" }

  s.platform     = :ios
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/netyouli/WHC_Layout.git", :tag => "1.0.0"}

  s.source_files  = "WHC_LayoutKit/*.{swift}"

  s.requires_arc = true


end

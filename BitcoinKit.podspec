Pod::Spec.new do |spec|
  spec.name = 'BitcoinKit'
  spec.version = '1.1.0'
  spec.summary = 'Bitcoin(BCH/BTC) protocol toolkit for Swift'
  spec.description = <<-DESC
    The BitcoinKit library is a Swift implementation of the Bitcoin(BCH/BTC) protocol. This library was originally made by Katsumi Kishikawa, and now is maintained by Yenom Inc. It allows maintaining a wallet and sending/receiving transactions without needing a full blockchain node. It comes with a simple wallet app showing how to use it.
  DESC
  spec.homepage = 'https://github.com/Whitehare2023/BitcoinKit'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'BitcoinKit developers' => 'usatie@yenom.tech' }

  spec.requires_arc = true
  spec.source = { git: 'https://github.com/Whitehare2023/BitcoinKit.git', branch: 'fix-secp256k1-build' }
  spec.source_files = 'Sources/BitcoinKit/**/*.{h,m,swift}'
  spec.exclude_files = 'Sources/**/LinuxSupport.swift'
  spec.ios.deployment_target = '8.0'
  spec.swift_version = '5.0'
end

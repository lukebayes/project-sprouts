
Sprout::Specification.new do |s|
  # This is the Specification that loads the Flex 4 SDK,
  # To use the Flex 4 SDK from your build tasks, you can
  # simply update the pkg_name parameter of your build
  # task as follows:
  #
  #   mxmlc 'bin/SomeProject.swf' do |t|
  #     t.input       = 'src/SomeProject.as'
  #     t.pkg_name    = 'flex4'
  #   end
  #
  # If you'd like to consume any of the libraries that
  # are included with the Flex SDK, you can embed them
  # from your Rakefile as follows:
  #
  #   library :f_textlayout
  #
  #   mxmlc 'bin/SomeProject.swf' => :f_textlayout do |t|
  #     t.input = 'src/SomeProject.as'
  #   end
  #
  # If you'd like to consume one of the localized frameworks
  # you can set that up as follows:
  #
  #   library 'flex_4_es_ES'
  #
  #   mxmlc 'bin/SomeProject.swf' => 'flex_4_es_ES' do |t|
  #     t.input = 'src/SomeProject.as'
  #   end
  #
  s.name    = 'flex4'
  s.version = '4.1.0.16076'

  s.add_remote_file_target do |t|
    t.platform     = :universal
    t.archive_type = :zip
    t.url          = "http://fpdownload.adobe.com/pub/flex/sdk/builds/flex4/flex_sdk_4.1.0.16076.zip"
    t.md5          = "4c5f3d3fa4e1f5be244679210cd852c0"

    # Executables: (add .exe suffix if it was passed in)
    t.add_executable :aasdoc,     "bin/aasdoc"
    t.add_executable :acompc,     "bin/acompc"
    t.add_executable :adl,        "bin/adl"
    t.add_executable :adt,        "bin/adt"
    t.add_executable :amxmlc,     "bin/amxmlc"
    t.add_executable :asdoc,      "bin/asdoc"
    t.add_executable :compc,      "bin/compc"
    t.add_executable :copylocale, "bin/compc"
    t.add_executable :digest,     "bin/digest"
    t.add_executable :fcsh,       "bin/fcsh"
    t.add_executable :fdb,        "bin/fdb"
    t.add_executable :mxmlc,      "bin/mxmlc"
    t.add_executable :optimizer,  "bin/optimizer"

    # Flex framework SWCs:
    t.add_library :flex,            "frameworks/libs/flex.swc"
    t.add_library :flex4,           "frameworks/libs/flex4.swc"
    t.add_library :f_textlayout,    "frameworks/libs/framework_textLayout.swc"
    t.add_library :framework,       "frameworks/libs/framework.swc"
    t.add_library :rpc,             "frameworks/libs/rpc.swc"
    t.add_library :sparkskins,      "frameworks/libs/sparkskins.swc"
    t.add_library :textlayout,      "frameworks/libs/textLayout.swc"
    t.add_library :utilities,       "frameworks/libs/utilities.swc"
    t.add_library :playerglobal_9,  "frameworks/libs/player/9/playerglobal.swc"
    t.add_library :playerglobal_10, "frameworks/libs/player/10/playerglobal.swc"

    # AsDoc templates:
    t.add_library :asdoc_templates, "asdoc/templates"

    # Locale-Specific Flex SWCs:
    [
      'da_DK', 'de_DE', 'en_US', 'es_ES', 'fi_FL', 'fr_FR', 'it_IT', 'ja_JP',
      'ko_KR', 'nb_NO', 'nl_NL', 'pt_BR', 'ru_RU', 'sv_SE', 'zh_CN', 'zh_TW'
    ].each do |locale|
      t.add_library "flex_4_#{locale}".to_sym,       "frameworks/locale/#{locale}/flex4_rb.swc"
      t.add_library "airframework_#{locale}".to_sym, "frameworks/locale/#{locale}/airframework_rb.swc"
      t.add_library "framework_#{locale}".to_sym,    "frameworks/locale/#{locale}/framework_rb.swc"
      t.add_library "rpc_#{locale}".to_sym,          "frameworks/locale/#{locale}/rpc_rb.swc"
    end
  end
end


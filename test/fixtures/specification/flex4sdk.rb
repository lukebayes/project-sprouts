# This is a sample Sprout Specification.
#
# This document describes the Flex 4 SDK in terms of the libraries and executables
# that is provides.
#
# Whenever this file is loaded (required) by a Ruby application that has already loaded
# the core sprout files, the remote_file_target will be downloaded and installed,
# and each executable and library will be available to any interested rake
# tasks.
#
# An example of how one might retrieve a path to the downloaded MXMLC executable is
# as follows:
#
#     Sprout.get_executable :mxmlc, 'flex4sdk', '>= 4.0.pre'
#
Sprout::Specification.new do |s|

  s.name    = 'flex4sdk'
  s.version = '4.0.pre'

  s.add_remote_file_target do |t|
    # Apply the windows-specific configuration:
    t.platform = :universal
    # Apply the shared platform configuration:
    # Remote Archive:
    t.archive_type = :zip
    t.url          = "http://download.macromedia.com/pub/labs/flex/4/flex4sdk_b2_100509.zip"
    t.md5          = "6a0838c5cb33145fe88933778ddb966d"

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



module Sprout
  
  # The Sprout::MXMLCFlexBuilder task is intended to 
  # transform Sprout::ProjectModel instances into Flex Builder Eclipse 
  # project files.
  #
  # This task should also be able to analyze Flex Builder project files
  # and emit a Sprout::ProjectModel based on the information found there.
  #
  # The current incarnation is a proof of concept and may not work properly,
  # but here is an example just in case:
  #
  # flex_builder :project
  #
  class MXMLCFlexBuilder < MXMLCHelper # :nodoc:
    PROJECT                  = '.project'
    ACTION_SCRIPT_PROPERTIES = '.actionScriptProperties'

    def initialize(args, &block)
      super
      outer_task = task args => [PROJECT, ACTION_SCRIPT_PROPERTIES]
      
      t = file PROJECT do |t|
        File.open(t.name, 'w') do |file|
          file.write t.to_xml
        end
      end
      configure_project_task t
      
      t = file ACTION_SCRIPT_PROPERTIES do |t|
        File.open(t.name, 'w') do |file|
          file.write t.to_xml
        end
      end
      configure_action_script_properties t
      
      return outer_task
    end

    def configure_project_task(project_task)
      def project_task.xml=(str)
        @xml = str
      end
      
      project_task.xml = <<EOF 
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
	<name>#{model.project_name}</name>
	<comment></comment>
	<projects>
	</projects>
	<buildSpec>
		<buildCommand>
			<name>com.adobe.flexbuilder.project.flexbuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
	</buildSpec>
	<natures>
		<nature>com.adobe.flexbuilder.project.actionscriptnature</nature>
	</natures>
</projectDescription>
EOF

      def project_task.to_xml
        return @xml
      end

    end
    
    def configure_action_script_properties(properties_task)
      def properties_task.xml=(str)
        @xml = str
      end
      
      str1 = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<actionScriptProperties mainApplicationPath="#{model.project_name}.as" version="3">
<compiler additionalCompilerArguments="--default-size #{model.width} #{model.height} --default-background-color #{model.background_color}" copyDependentFiles="false" enableModuleDebug="true" flexSDK="Flex 3" generateAccessible="false" htmlExpressInstall="true" htmlGenerate="false" htmlHistoryManagement="true" htmlPlayerVersion="9.0.28" htmlPlayerVersionCheck="true" outputFolderPath="bin" sourceFolderPath="src" strict="true" useApolloConfig="false" verifyDigests="true" warn="true">
<compilerSourcePath>
EOF
      str2 = ""
      model.source_path.each do |path|
        str2 << "<compilerSourcePathEntry kind=\"1\" linkType=\"1\" path=\"#{path}\"/>\n"
      end
      
      str3 = <<EOF
</compilerSourcePath>
<libraryPath defaultLinkType="1">
<libraryPathEntry kind="4" path="">
<excludedEntries>
EOF
      str4 = <<EOF
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/automation_agent.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/automation.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="1" linkType="1" path="${PROJECT_FRAMEWORKS}/locale/{locale}"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/automation_flashflexkit.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/qtp.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/charts.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/rpc.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/automation_charts.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/datavisualization.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/automation_dmv.swc" useDefaultLinkType="false"/>
<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/framework.swc" useDefaultLinkType="false"/>
</excludedEntries>
</libraryPathEntry>
EOF
      str5 = ""
      model.library_path.each do |path|
        str5 << "<libraryPathEntry kind=\"1\" linkType=\"1\" path=\"#{path}\"/>\n"
      end

      str6 = <<EOF
</libraryPath>
<sourceAttachmentPath/>
</compiler>
<applications>
<application path="#{model.project_name}.as"/>
</applications>
<modules/>
<buildCSSFiles/>
</actionScriptProperties>
EOF

      properties_task.xml = str1 + str2 + str3 + str4 + str5 + str6

      def properties_task.to_xml
        return @xml
      end

    end
    
  end
end

def flex_builder(args, &block)
  return Sprout::MXMLCFlexBuilder.new(args, &block)
end

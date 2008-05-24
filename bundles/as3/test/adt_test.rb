require File.dirname(__FILE__) + '/test_helper'

class ADTTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start        = Dir.pwd
    fixture      = File.join(fixtures, 'adt')
    
    @storetype = "PKCS12"
    @keystore = "cert.p12"
    @keypass = "thepassword"
    @output = "bin/TestProj.air"
    @application_descriptor = "src/SomeProject-app.xml"
    @files = [ "assets", "skins" ]

    Dir.chdir(fixture)
  end
  
  def teardown
    Dir.chdir(@start)
    super
  end

  # Test launcher task
  def test_packager
    packager = adt :package do |t|
      t.storetype = @storetype
      t.keystore = @keystore
      t.keypass = @keypass
      t.output = @output
      t.application_descriptor = @application_descriptor
      t.files = @files
    end
    
    command = "-package -storetype PKCS12 -keystore cert.p12 -keypass thepassword bin/TestProj.air src/SomeProject-app.xml assets skins"    
    assert_equal command, packager.to_shell      
  end
  
  def test_certificate
    certificate = adt_cert :certificate do |t|
      t.cn = "Common name"
      t.o = "Organization"
      t.ou = "Organizational unit"
      t.c = "US"
      t.keytype = "1024-RSA"
      t.keystore = @keystore
      t.keypass = @keypass
    end
    
    command = "-certificate -cn Common\\ name -ou Organizational\\ unit -o Organization -c US 1024-RSA cert.p12 thepassword"
    
    assert_equal command, certificate.to_shell      
  end
  
end



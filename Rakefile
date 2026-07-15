desc "installs PlcTag for ruby"
task :install, [:gem] do
  if File.exist?("build")
    sh "rm -rf build/libplctag-vala"
  end

  sh "mkdir -p build"

  Dir.chdir "build"

  sh "git clone https://github.com/ppibburr/libplctag-vala.git"
  sh "cd libplctag-vala && /usr/local/bin/valabind --gir -m PlcTag --namespace PlcTag -l libplctag.so -o PlcTag-1.0.gir PlcTag-1.0.vapi"
  sh "cd libplctag-vala && ruby ../../tools/girfix.rb ./PlcTag-1.0.gir"
  sh "cd libplctag-vala && g-ir-compiler --shared-library=libplctag PlcTag-1.0.gir > PlcTag-1.0.typelib"
  sh "cd libplctag-vala && sudo cp PlcTag-1.0.typelib /usr/lib/girepository-1.0/"

  Dir.chdir ".."

  sh "sudo gem i -l ./PlcTag-0.0.1.gem"
  
end

desc "make gem file"
task :gem do
  sh "gem build plctag.gemspec"
end

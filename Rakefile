ROOT = File.dirname(__FILE__)

# Add the project lib to the load path
$LOAD_PATH << File.join(ROOT, 'lib')
# Load the task definitions for the project
FileList[File.join(ROOT, 'lib', 'tasks', '**', '*.rake')].each do |f|
  Rake.application.add_import f
end

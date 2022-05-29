#!/usr/bin/env ruby
# share_schemes.rb

require 'xcodeproj'

# This function extract PRODUCT_NAME from xcscheme: SP-INTERN
# Then combine PRODUCT_NAME with current version
# returns buildable name that will be saved (SP-INTERN-5.9.29.app)
def newBuildableName(buildableName, version)
    puts "NewBuildableName ---> #{buildableName}"
    if buildableName.include?(".xctest")
        return ""
    end
    nameArray = buildableName.split('-')
    if nameArray.count > 1
        currentProductName = nameArray[0] + "-" + nameArray[1]
        return productName(currentProductName, version)
    end
    return ""
end

# return SP-INTERN-5.9.29.app
def productName(productName, version)
    begin
        return productName + "-" + version + ".app"
    rescue
        puts "Exception: Unable to create product name"
    end
end

def change_buildable_reference(action, version)
    [action].each do |buildable_reference|
        buildableName = newBuildableName(buildable_reference.buildable_name, version)
        if buildableName != ""
            puts "Buildable name changed: #{buildableName}"
            buildable_reference.buildable_name = buildableName
        end
    end
end

#Update build actions
def update_build_action(scheme, version)
    puts "\n ############ Build actions ############"
    buildEntries = scheme.build_action.entries
    for entry in buildEntries do
        buildAction = entry.buildable_references[0]
        change_buildable_reference(buildAction, version)
    end
end

#Update launch action
def update_launch_action(scheme, version)
    puts "\n ############ Launch action ############"
    if scheme.launch_action.macro_expansions.count == 0
        launchAction = scheme.launch_action.buildable_product_runnable.buildable_reference
        change_buildable_reference(launchAction, version)
    else
        puts "\n Por el else : #{scheme.launch_action.macro_expansions[0].buildable_reference}"
        launchAction = scheme.launch_action.macro_expansions[0].buildable_reference      
        change_buildable_reference(launchAction, version)
    end
end

#Update profile actions
def update_profile_action(scheme, version)
    puts "\n ############ Profile Action ############"
    profileAction = scheme.profile_action.buildable_product_runnable.buildable_reference
    change_buildable_reference(profileAction, version)
end

## XCScheme ##
def update_scheme(project, scheme, version)
    puts "\n **************  Modifying XCScheme #{scheme} ************** "

    # Open scheme
    scheme_path = Xcodeproj::XCScheme.shared_data_dir(project.path) + scheme
    scheme = Xcodeproj::XCScheme.new(scheme_path)

    # BuildAction
    update_build_action(scheme, version)

    # LaunchAction
    update_launch_action(scheme, version)

    # ProfileAction
    update_profile_action(scheme, version)

    puts "\n **************  Finish ************** "
    scheme.save!
end

# Loops all schemes in shared xcshareddata/xcschemes
def update_schemes(projectPath, version)
    puts "Version:" + version
    begin
        project = Xcodeproj::Project.open(projectPath)
    rescue
        puts "Exception: Unable to open the project with path " + project_path
    end
    shared_data_dir = Xcodeproj::XCScheme.shared_data_dir(project.path)
    Dir.foreach(shared_data_dir) do |filename|
        next if not filename.include? "xcscheme"
        update_scheme(project, filename, version)
    end
end
# Define the minimal Fastlane version
fastlane_version "1.41.1"

# Use the iOS platform as default
default_platform :ios

# Define what to do for the iOS platform
platform :ios do

# Run this before doing anything else
before_all do


end

# After all the steps have completed succesfully, run this.
after_all do |lane|

  # Remove all build artifacts, but keep mobileprovisioning profiles since they are stored in GIT
  clean_build_artifacts(
    exclude_pattern: ".*\.mobileprovision"
  )

  # Reset all changes to the git checkout
  

end

# If there was an error, run this
error do |lane, exception|

  # Remove all build artifacts, but keep mobileprovisioning profiles since they are stored in GIT
  clean_build_artifacts(
    exclude_pattern: ".*\.mobileprovision"
  )

  # Reset all changes to the git checkout
  

end

private_lane :build_app do |options|

  # This part is done only when the app is not for the "production" environment
  if not options[:release]
    # Modulate the color of the icons
    color_icon(
      modulation: "#{options[:modulation]}"
    )
    # Add the build number to the icon
    build_number_icon
  end

  # Update the app name
  app_name(
    plist_path: "#{options[:project_name]}/Info.plist",
    app_name: options[:app_name]
  )

  # Update the app identifier
  update_app_identifier(
    xcodeproj: "#{options[:project_name]}.xcodeproj",
    plist_path: "#{options[:project_name]}/Info.plist",
    app_identifier: options[:app_identifier]
  )

  # Install the certificate
  import_certificate(
    certificate_path: options[:certificate_path],
    certificate_password: options[:certificate_password],
    keychain_name: "login.keychain"
  )

  # Install the provisioning profile
  update_project_provisioning(
    xcodeproj: "#{options[:project_name]}.xcodeproj",
    profile: options[:profile]
  )


  # Build the app
  gym(
    scheme: "#{options[:scheme]}",
    export_method: options[:export_method]
  )

end

# Publish to Testflight
private_lane :publish_testflight do |options|

  # Send the app to Testflight
  pilot(
    changelog: "#{changelog.to_s}"
  )
end

# Publish to Hockeyapp
private_lane :publish_hockey do |options|

  # Send the app to Hockeyapp (fill in your API token!)
  hockey(
    api_token: "67c77a7c9c634fd49c52c88409cba9a7",
    notes: "testasads",
    release_type: options[:release_type]
  )
end

# Publish to the AppStore
private_lane :publish_appstore do |options|
  deliver(force: true)
end

# Build and publish the Alpha version to Hockeyapp
lane :alpha_hockeyapp do
  # Build
  build_app(
    # Not a production release, so add build number and do the color modulation of the icons
    release:false,
    # Modulate the colors of the icons by these degrees
    modulation:66.6,
    # Change the app name
    app_name:"FastlaneDemo α",
    # Set the app id
    app_identifier:"com.seic.testid",
    # Set the path to the certificate to use in building
    certificate_path:"./fastlane/certs/Certificates.p12",
    # Set the password of the p12 certificate file
    certificate_password:"1234",
    # Set the path to the provisioning profile to use (change this!)
    profile:"./fastlane/certs/Test_Dist.mobileprovision",
    # What configuration to use, usefull for keeping different API keys etc between environments
    configuration:"Alpha",
    # Use this codesigning identity (this is the name of the certificate in your keychain)
    codesigning_identity:"iPhone Distribution: SEI Global Services, Inc.",
    # Export an enterprise app
    export_method:"enterprise",
    # the projectname, this is the name of the .xcodeproj file and the folder containing your code in the project
    project_name:"TestPushDown",
    # the scheme to build
    scheme:"TestPushDown",
  )
  # Push to Hockeyapp as Alpha release
  publish_hockey(release_type: "2")
end

# Build and publish the Beta version to Hockeyapp
lane :beta_hockeyapp do
  # Build
  build_app(
    # Not a production release, so add build number and do the color modulation of the icons
    release:false,
    # Modulate the colors of the icons by these degrees
    modulation:166.6,
    # Change the app name
    app_name:"FastlaneDemo β",
    # Set the app id
    app_identifier:"com.seic.testid",
    # Set the path to the certificate to use in building
    certificate_path:"./fastlane/certs/<your key>.p12",
    # Set the password of the p12 certificate file
    certificate_password:"<your p12 password>",
    # Set the path to the provisioning profile to use (change this!)
    profile:"./fastlane/certs/KunstmaanLabsFastlaneDemoApp_Beta.mobileprovision",
    # What configuration to use, usefull for keeping different API keys etc between environments
    configuration:"Beta",
    # Use this codesigning identity (this is the name of the certificate in your keychain)
    codesigning_identity:"iPhone Distribution: Kunstmaan NV",
    # Export an enterprise app
    export_method:"enterprise",
    # the projectname, this is the name of the .xcodeproj file and the folder containing your code in the project
    project_name:"KunstmaanLabsFastlaneDemoApp",
    # the scheme to build
    scheme:"KunstmaanLabsFastlaneDemoApp",
    # the build number to use, we use the build number from Jenkins
    build_number: ENV["BUILD_NUMBER"]
  )
  # Push to Hockeyapp as Beta release
  publish_hockey(release_type: "0")
end

# Build and publish the Release version to Hockeyapp
lane :release_hockeyapp do
  # Build
  build_app(
    # Not a production release, so add build number and do the color modulation of the icons
    release:true,
    # Change the app name
    app_name:"FastlaneDemo",
    # Set the app id
    app_identifier:"com.seic.testid",
    # Set the path to the certificate to use in building
    certificate_path:"./fastlane/certs/<your key>.p12",
    # Set the password of the p12 certificate file
    certificate_password:"<your p12 password>",
    # Set the path to the provisioning profile to use (change this!)
    profile:"./fastlane/certs/KunstmaanLabsFastlaneDemoApp_Release.mobileprovision",
    # What configuration to use, usefull for keeping different API keys etc between environments
    configuration:"Release",
    # Use this codesigning identity (this is the name of the certificate in your keychain)
    codesigning_identity:"iPhone Distribution: Kunstmaan NV",
    # Export an enterprise app
    export_method:"enterprise",
    # the projectname, this is the name of the .xcodeproj file and the folder containing your code in the project
    project_name:"KunstmaanLabsFastlaneDemoApp",
    # the scheme to build
    scheme:"KunstmaanLabsFastlaneDemoApp",
    # the build number to use, we use the build number from Jenkins
    build_number: ENV["BUILD_NUMBER"]
  )
  # Push to Hockeyapp as Enterprise release
  publish_hockey(release_type: "3")
end

# Build and publish the Release version to the AppStore
lane :release_appstore do
  # Build
  build_app(
    # Not a production release, so add build number and do the color modulation of the icons
    release:true,
    # Change the app name
    app_name:"FastlaneDemo",
    # Set the app id
    app_identifier:"com.seic.testid",
    # Set the path to the certificate to use in building
    certificate_path:"./fastlane/certs/<your key>.p12",
    # Set the password of the p12 certificate file
    certificate_password:"<your p12 password>",
    # Set the path to the provisioning profile to use (change this!)
    profile:"./fastlane/certs/KunstmaanLabsFastlaneDemoApp_Release.mobileprovision",
    # What configuration to use, usefull for keeping different API keys etc between environments
    configuration:"Release",
    # Use this codesigning identity (this is the name of the certificate in your keychain)
    codesigning_identity:"iPhone Distribution: Kunstmaan NV",
    # Export an enterprise app
    export_method:"app-store",
    # the projectname, this is the name of the .xcodeproj file and the folder containing your code in the project
    project_name:"KunstmaanLabsFastlaneDemoApp",
    # the scheme to build
    scheme:"KunstmaanLabsFastlaneDemoApp",
    # the build number to use, we use the build number from Jenkins
    build_number: ENV["BUILD_NUMBER"]
  )
  # Push to the appstore
  publish_appstore
end

end
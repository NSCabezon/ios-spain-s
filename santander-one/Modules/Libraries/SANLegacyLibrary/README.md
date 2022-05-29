# SANLegacyLibrary

## Requirements

## Installation

After checking out the branch, you'll notice that there is no `xcodeproj` file. That is because we're using [xcodegen](https://github.com/yonaskolb/XcodeGen) to dynamically build our project and various targets in order to mitigate merge conflicts when working on a mono-repo.

You'll first need to install the [xcodegen](https://github.com/yonaskolb/XcodeGen) command tool first (please follow instructions on the tool's github page).

When it's done, open a terminal on the project's root and run:

```shell
xcodegen
```

Once the project file has been generated, you can then run `cocoapods` to install additional required dependencies.

```shell
pod install
```

And that's it. You can now open `SANLegacyLibrary.xcworkspace`

Additionally you can use both commands in the same instructions as follows

```shell
xcodegen && pod deintegrate && pod install
```

**NOTE:**
It is preferable to run those 2 commands after pulling new code from the repository as it might include changes to the `project.yml` file (which includes the different rules defining how the project, its target, schemes, etc are built).



SANLegacyLibrary is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SANLegacyLibrary'
```

## Author

Francisco Lorenzo, francisco.lorenzo@servexternos.gruposantander.com

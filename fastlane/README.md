fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios create_app_id

```sh
[bundle exec] fastlane ios create_app_id
```

Create app id

### ios certificates

```sh
[bundle exec] fastlane ios certificates
```

Fetch certificates and provisioning profiles (passphrase: Santander2021)

### ios certificates_release

```sh
[bundle exec] fastlane ios certificates_release
```

Fetch Distribution certificates and provisioning profiles

### ios update_pods

```sh
[bundle exec] fastlane ios update_pods
```

Updating pods and Provisions

### ios swift_lint

```sh
[bundle exec] fastlane ios swift_lint
```

Pass swiftlint

### ios clean_repo

```sh
[bundle exec] fastlane ios clean_repo
```



### ios release

```sh
[bundle exec] fastlane ios release
```



### ios build_for_test

```sh
[bundle exec] fastlane ios build_for_test
```

Build for all test

### ios test

```sh
[bundle exec] fastlane ios test
```

Test all example apps

### ios generate_changelog

```sh
[bundle exec] fastlane ios generate_changelog
```



### ios build_appium

```sh
[bundle exec] fastlane ios build_appium
```



### ios ensure_strings_update

```sh
[bundle exec] fastlane ios ensure_strings_update
```



### ios increment_version

```sh
[bundle exec] fastlane ios increment_version
```

Incrementing Version

### ios push_tag

```sh
[bundle exec] fastlane ios push_tag
```



### ios update_version_in_plist_extensions

```sh
[bundle exec] fastlane ios update_version_in_plist_extensions
```



### ios beta

```sh
[bundle exec] fastlane ios beta
```



### ios branch_equilibrium

```sh
[bundle exec] fastlane ios branch_equilibrium
```



### ios certificates_vostok

```sh
[bundle exec] fastlane ios certificates_vostok
```



### ios build_vostok

```sh
[bundle exec] fastlane ios build_vostok
```



### ios build_vostok_distribution

```sh
[bundle exec] fastlane ios build_vostok_distribution
```



### ios sonarQ_vostok

```sh
[bundle exec] fastlane ios sonarQ_vostok
```

SonarQ Vostok

### ios getProjectVersion_vostok

```sh
[bundle exec] fastlane ios getProjectVersion_vostok
```

Get project version VOSTOK

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

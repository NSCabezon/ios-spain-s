# iOS Spain - INSTALL.md


#### References


* Core repository - [INSTALL.md](https://github.com/santander-group-europe/ios-santander-one/blob/master/INSTALL.md)
* Portugal repository - [INSTALL.md]((https://github.com/santander-group-europe/ios-portugal/blob/master/INSTALL.md))
* Poland repository - [INSTALL.md](https://github.com/santander-group-europe/ios-spain/blob/master/INSTALL.md)
 
#### Clone Source Code Santander Spain

First we have to create an RSA key pair.

```bash

ssh-keygen -t rsa
```

Copy the key to clipboard.
```bash
pbcopy < ~/.ssh/id_rsa.pub
```
Configure the keys in github.

[GitHub Documentation](https://docs.github.com/es/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

Configure the authenticating to a github santander-group-europe with SAML single sign on.

[Stackoverflow reference](https://stackoverflow.com/questions/51634406/git-push-is-not-working-error-you-must-use-a-personal-access-token-or-ssh-key)

```bash

~ jouahbi$ git clone --recurse-submodules --remote-submodules git@github.com:santander-group-europe/ios-spain.git
```

Install the project dependencies using cocoapods.

```bash

cd ios-spain/
pod install

Analyzing dependencies

[!] Oh no, an error occurred.

LoadError - dlopen(/Library/Ruby/Gems/2.6.0/gems/ffi-1.15.3/lib/ffi_c.bundle, 0x0009): missing compatible arch in /Library/Ruby/Gems/2.6.0/gems/ffi-1.15.3/lib/ffi_c.bundle - /Library/Ruby/Gems/2.6.0/gems/ffi-1.15.3/lib/ffi_c.bundle
...

```
MacBook Pro with a M1 processor?
[MacBook Pro with a M1 Solution](https://armen-mkrtchian.medium.com/run-cocoapods-on-apple-silicon-and-macos-big-sur-developer-transition-kit-b62acffc1387)

Open a rosetta terminal.

```bash
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
```

Open the generated workspace.


 


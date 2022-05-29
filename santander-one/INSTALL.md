# OneApp Santander


Welcome to OneApp Santander iOS Core.
This project provides the iOS Core functionalities for any country app for the OneApp application.


### Note
It is not a standalone repository, but is included as a sub-module from the local repository of each country.


#### References

* Spain repository - [INSTALL.md](https://github.com/santander-group-europe/ios-spain/blob/master/INSTALL.md)
* Portugal repository - [INSTALL.md]((https://github.com/santander-group-europe/ios-portugal/blob/master/INSTALL.md))
* Poland repository - [INSTALL.md](https://github.com/santander-group-europe/ios-spain/blob/master/INSTALL.md)
 

#### Clone Santander One Source Code

First we have to create an RSA key pair.

```bash

$ ssh-keygen -t rsa
Generating public/private rsa key pair.
```
Copy the key to clipboard.

```bash
pbcopy < ~/.ssh/id_rsa.pub
```
Configure the keys in github.

[GitHub Documentation](https://docs.github.com/es/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

Configure the authenticating to a github santander-group-europe with SAML single sign on if needed.

[StackOverflow Reference](https://stackoverflow.com/questions/51634406/git-push-is-not-working-error-you-must-use-a-personal-access-token-or-ssh-key)

Clone project and submodules:

```bash

$ git clone --recurse-submodules --remote-submodules git@github.com:santander-group-europe/ios-santander-one.git
Cloning into 'ios-santander-one'...
```

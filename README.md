# Rename Finder Items by Pattern

An action for Mac OS X Automator, version 10.6. To install, just 
double-click.

Works similarly to the built in _Rename Finder Items_ action, but uses
a wildcard pattern and a substitution pattern to selectively choose
parts of the current file name to use in the new file name.

In the search pattern, use one or more wildcards, an asterisk "*", to
match parts of the original file name and tokens in the replacement.
The tokens are dollar signs "$" followed by the number of the wildcard
match in the search pattern.

It's easier to picture than describe.

For example, assume this file name: `abc - xyz.123 (d).png`
And this search pattern: `* - *.* (*)`

This will yield four matches that can be used in the replacement 
pattern like so:

* $1 = abc
* $2 = xyz
* $3 = 123
* $4 = d

So, this replacement pattern: `Type $4 Section $3 Bldg $2 in Region $1`
Give this result: `Type d Section 123 Bldg xyz in Region abc`

### Acknowledgements

Thanks to Daniel Calcoen for the tweaks to the Xcode project! Now builds
and runs in the latest Xcode and OS X.
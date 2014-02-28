# Go language support in Atom

Adds syntax highlighting and snippets to Go files in Atom.

Originally [converted](http://atom.io/docs/latest/converting-a-text-mate-bundle)
from the [Go TextMate bundle](https://github.com/rsms/Go.tmbundle).

Contributions are greatly appreciated. Please fork this repository and open a
pull request to add snippets, make grammar tweaks, etc.

## Ctags and the Symbols View

In order for the symbols view to work with Go code, you'll need to configure
ctags.

#### OSX

Add the following to ~/.ctags


```
--langdef=Go
--langmap=Go:.go
--regex-Go=/func([ \t]+\([^)]+\))?[ \t]+([a-zA-Z0-9_]+)/\2/f,func/
--regex-Go=/var[ \t]+([a-zA-Z_][a-zA-Z0-9_]+)/\1/v,var/
--regex-Go=/type[ \t]+([a-zA-Z_][a-zA-Z0-9_]+)/\1/t,type/
```

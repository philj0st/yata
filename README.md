# YATΛ
Yet another todo application! this one is implemented in Racket and aimed towards quick cli-usage. I'm using `dialog` and `whiptail` for the user interface which allows for a smooth cross-platform / non-gui-required experience :)
![cli-callable todo](http://i.imgur.com/HAp3v6V.gif)

### Roadmap
- [x] spawn dialog/whiptail and let the childprocess capture stdin and stdout of the parent process (thanks @cky !).
- [x] parse Racket list to dialog/whiptail arguments (called it argify :smile_cat:)
- [x] read/write todo list in data mode
- [x] parse dialog/whiptail's return value to actual changes
- [x] stack/chain dialogs for adding a new todo
- [ ] menu for CRUD on todos
- [ ] connect with google todo api

### FAQ
_where are my todos saved?_

Yata uses `(build-path (find-system-path 'home-dir) ".racket" "yata" "todos.rkt"))` which will eventually end up saving them somewhere like `/home/phil/.racket/yata/todos.rkt` if you're on linux

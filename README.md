# YATΛ :ballot_box_with_check:
**Y**et **a**nother **t**odo **a**pplication! Λ uppercase lambda because it's implemented in Racket. Leveraging `Dialog`/`Whiptail` to print a GUI to a terminal.

Yata is a tool that lets you create, remove, update, delete and toggle todos from your shell. It spawns Dialog/Whiptail dialogs as child processes, sends all the standard input to the child process and redirects the child processes standard output back to the parent shell process where it was invoked.

![cli-callable todo](http://i.imgur.com/BaKWJsw.gif)

### Roadmap
- [x] spawn dialog/whiptail and let the childprocess capture stdin and stdout of the parent process (thanks @cky !).
- [x] parse Racket list to dialog/whiptail arguments (called it argify :smile_cat:)
- [x] read/write todo list in data mode
- [x] parse dialog/whiptail's return value to actual changes
- [x] stack/chain dialogs for adding a new todo
- [x] Create
- [x] Read
- [x] Update
- [x] Delete
- [ ] decouple dialog module so that unsorted-todo-list -> unsorted-todo-list with changes. Sorting and indexing gets abstracted within dialog module.
- [x] menu for CRUD on todos
- [ ] connect with google todo api

### FAQ
_where are my todos saved?_

Yata uses `(build-path (find-system-path 'home-dir) ".racket" "yata" "todos.rkt"))` which will eventually end up saving them somewhere like `/home/phil/.racket/yata/todos.rkt` if you're on linux

### Installation
I'm afraid at the moment there's no other way than to build from source :construction_worker:. This can be achieved by cloning this directory and then use some IDE like *DrRacket* which has the option to *Racket*->*Create Executable*.

### Known issues
dialog/whiptail's `--checklist` returns an empty string if the dialog gets cancelled but also if no todos are checked. If all Todos are unchecked but one and this only checked one gets unchecked the new state won't be saved because it's more likely to be a cancelled dialog.

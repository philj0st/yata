#!/bin/bash
DIALOG=${DIALOG=dialog}
$DIALOG --title " My first dialog" --clear --yesno "Hello , this is my first dialog program" 10 30
echo $?

$DIALOG           --clear --inputbox "New Todo" 18 60 \
    --and-widget --clear --inputbox "Priority" 18 60 \

echo $?

$DIALOG --menu "YATA Main Menu" 18 60 20 1 "Toggle Todos" 2 "Add Todo" 3 "Remove Completed" 4 "Quit"

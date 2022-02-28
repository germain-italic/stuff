#!/bin/bash

# save this script to ~/.local/share/nautilus/scripts/mail-file.sh
# then chmod +x ~/.local/share/nautilus/scripts/mail-file.sh

# the companion blog post:
# https://www.germain.lol/gnome-menu-contextuel-pour-envoyer-un-fichier-par-mail/

# some references that helped me:
# https://help.ubuntu.com/community/NautilusScriptsHowto
# https://help.ubuntu.com/community/NautilusScriptsHowto/SampleScripts
# https://help.gnome.org/users/zenity/3.32/
# https://renenyffenegger.ch/notes/Linux/shell/commands/zenity
# https://mailutils.org/manual/html_section/index.html
# https://stackoverflow.com/questions/2138701/checking-correctness-of-an-email-address-with-a-regular-expression-in-bash

# DEBUG: show all variables sent by Nautilus
# zenity --info --text="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS $NAUTILUS_SCRIPT_SELECTED_URIS $NAUTILUS_SCRIPT_CURRENT_URI $NAUTILUS_SCRIPT_WINDOW_GEOMETRY"

# DEBUG: force filename and path
# NAUTILUS_SCRIPT_SELECTED_FILE_PATHS='/home/germain/Téléchargements/invoice-4214667.pdf'


# required dependency:
# sudo apt-get install zenity
ZENITY='/usr/bin/zenity'
ZENITY_PROGRESS_OPTIONS='--auto-close --auto-kill' #you can remove this if you like
ZENITY_MSG_WIDTH='--width=300'

# required dependency:
# sudo apt-get install postfix libsasl2-modules mailutils
# Postfix config available at https://www.germain.lol/relais-stmp-mandrill-via-postfix/
MAIL='/usr/bin/mail'


REGEXMAIL="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"



SENDER="sender@domain.com"
SENDER_CONFIRMED=$($ZENITY --entry --title="Confirm sender" --text="Who are you?" --entry-text="$SENDER" $ZENITY_MSG_WIDTH)
if [[ ! $SENDER_CONFIRMED =~ $REGEXMAIL ]] ; then
    $ZENITY --error --text="Error: $SENDER_CONFIRMED looks invalid." $ZENITY_MSG_WIDTH
    exit 0
fi


# add one recipient per line below
RECIPIENT_CONFIRMED=$($ZENITY --list \
  --editable \
  --title="Recipient" \
  --text="Select a recipient:" \
  --column="Recipient" \
  "recipient1@domain.com" \
  "recipient2@domain.com" \
  "recipient3@domain.com" \
  "Custom (double click to edit)" \
)
if [[ ! $RECIPIENT_CONFIRMED =~ $REGEXMAIL ]] ; then
    $ZENITY --error --text="Error: $RECIPIENT_CONFIRMED looks invalid." $ZENITY_MSG_WIDTH
    exit 0
fi


MSG="Hello,\nPlease find attached file.\nBest regards."
MSG_CONFIRMED=$($ZENITY --entry --title="Confirm message" --text='Email body\n(Hint: use \\n for linebreaks):' --entry-text="$MSG" $ZENITY_MSG_WIDTH)


echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while read FILENAME; do
    if [ -n "${FILENAME}" ]
    then

        REALNAME=`basename "$FILENAME"`

        if $($ZENITY --question --title="Confirm file" --text="Send $REALNAME?" $ZENITY_MSG_WIDTH)
        then
            OUTPUT=$($MAIL -s "$SENDER_CONFIRMED sent you $REALNAME" -a "From:$SENDER_CONFIRMED" $RECIPIENT_CONFIRMED -A "$FILENAME" <<< $(echo -e $MSG_CONFIRMED) 2>&1 1>/dev/null)

            if [ -z "$OUTPUT" ]
            then
                $ZENITY --info --text="Success! $REALNAME sent to $RECIPIENT_CONFIRMED" $ZENITY_MSG_WIDTH
            else
                $ZENITY --error --text="Error: $REALNAME could not be sent.\n$OUTPUT" $ZENITY_MSG_WIDTH
            fi
        fi        
    fi
done

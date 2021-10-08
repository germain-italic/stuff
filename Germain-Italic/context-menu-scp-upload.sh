#!/bin/bash

# save this script to ~/.local/share/nautilus/scripts/upload.sh
# then chmod +x ~/.local/share/nautilus/scripts/upload.sh

# the companion blog post with screenshots was posted at:
# https://www.germain.lol/gnome-menu-contextuel-pour-uploader-un-fichier-via-scp/

# some references that helped me:
# https://help.ubuntu.com/community/NautilusScriptsHowto
# https://help.ubuntu.com/community/NautilusScriptsHowto/SampleScripts
# https://help.gnome.org/users/zenity/3.32/
# http://www.b2ck.com/~nicoe/pygtk-doc/pango-markup-language.html

# DEBUG: show all variables sent by Nautilus
# zenity --info --text="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS $NAUTILUS_SCRIPT_SELECTED_URIS $NAUTILUS_SCRIPT_CURRENT_URI $NAUTILUS_SCRIPT_WINDOW_GEOMETRY"

# DEBUG: force filename and path
# NAUTILUS_SCRIPT_SELECTED_FILE_PATHS='/home/germain/Téléchargements/Envato Market Receipt.pdf'
# NAUTILUS_SCRIPT_SELECTED_FILE_PATHS='/home/germain/Téléchargements/df.txt'


REMOTE=user@remote
REMOTE_PATH="/path/to/folder/"
PREFIX="https://www.public.url/"

# required dependency:
# sudo apt-get install xclip
XCLIP='/usr/bin/xclip'

# required dependency:
# sudo apt-get install zenity
ZENITY='/usr/bin/zenity '
ZENITY_PROGRESS_OPTIONS='--auto-close --auto-kill' #you can remove this if you like
ZENITY_MSG_WIDTH='--width=600'

echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while read FILENAME; do
    if [ -n "${FILENAME}" ]
    then
        BASENAME=`basename "$FILENAME"`
        REMOTE_FILENAME="${REMOTE_PATH}${BASENAME}"
        # test -e: checks if file exists
        # test -s: checks if file exists and size > 0
        ssh $REMOTE "test -s '${REMOTE_FILENAME}'" | $($ZENITY --progress --text="Testing <tt>$BASENAME</tt>" --pulsate   $ZENITY_PROGRESS_OPTIONS)
        if [ ${PIPESTATUS[0]} == 0 ]; then
            $ZENITY --error --text="Error: <tt>$BASENAME</tt> already exists in <tt>$REMOTE_FILENAME</tt>\nPlease rename the local or the remote file." $ZENITY_MSG_WIDTH
            exit
        else
            SCP=`scp "$FILENAME" $REMOTE:$REMOTE_PATH | $($ZENITY --progress --text="Uploading $REMOTE_PATH" --pulsate   $ZENITY_PROGRESS_OPTIONS)`
            TMP=${FILENAME##*/}
            URL=${PREFIX}${TMP}
            if [ $? -eq 0 ]
            then
                $ZENITY --info --text="Success! File uploaded to:\n<a href=\"$URL\"><tt>$URL</tt></a>" $ZENITY_MSG_WIDTH
                echo "$URL" | xclip -selection clipboard
            else
                $ZENITY --error --text="Error: SCP failed." $ZENITY_MSG_WIDTH
                exit
            fi
        fi
    fi
done

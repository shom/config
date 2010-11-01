#feh --bg-scale ~/pic/wallpaper/IMG_2029.JPG &
xrdb ~/.Xresources &

export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE="scim"
export QT_IM_MODULE="scim"
scim -d &

exec awesome

#export XDG_MENU_PREFIX=gnome-
#exec gnome-session

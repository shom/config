#!/bin/bash
bakdir=/home/shom/backup/config
rsync="rsync --recursive --links --safe-links --perms --times --compress --force --whole-file --delete --stats --timeout=180 --verbose"
cp /etc/make.conf $bakdir
$rsync /etc/portage $bakdir -r
cp /etc/mpd.conf $bakdir
cp /etc/conf.d/net $bakdir
cp /etc/hosts $bakdir

cp /usr/src/linux/.config $bakdir/kernel.config

cp ~/.fonts.conf $bakdir
$rsync ~/.config/awesome $bakdir -r
cp ~/.lscolor256 $bakdir/.lscolor256
cp ~/.mplayer/config $bakdir/mplayer.config
cp ~/.ncmpcpp/config $bakdir/ncmpcpp.config
cp ~/.rtorrent.rc $bakdir
cp ~/.ssh/config $bakdir/ssh.config
$rsync ~/.vim $bakdir -r
cp ~/.vimrc $bakdir
cp ~/.xinitrc $bakdir
cp ~/.Xresources $bakdir
cp ~/.zshrc $bakdir
cp ~/.zlogout $bakdir


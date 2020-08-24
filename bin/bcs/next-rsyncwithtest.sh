for dirNames in \
  "apacheds" \
  "apacheds2" \
  "axisrepo" \
  "bcsreports" \
  "bin" \
  "conf" \
  "conf_samples" \
  "customlibs" \
  "data" \
  "doc" \
  "install" \
  "reportengine" \
  "updatesite" \
  "webapp";
do
  #echo $dirNames
  rsync -avP --delete /opt/projektron/bcs/server/$dirNames/ /opt/projektron/bcs/server_next/$dirNames
done

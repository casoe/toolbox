# Redirect stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
exec > >(tee -ia tomcat-install.log)
exec 2>&1

# Tomcat in die richtigen Verzeichnisse kopieren
cp -vR tomcat ../server/
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs-test' ]]; then
  cp -vR tomcat ../server_next/
fi

# Tomcat Native Library systemweit installieren
cd tomcat-native/native/
make install

# Nur sicherheitshalber
ldconfig

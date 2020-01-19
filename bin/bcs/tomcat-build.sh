rm -f tomcat-build.log

# Redirect stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
exec > >(tee -ia tomcat-build.log)
exec 2>&1

# Die letzte beste Version vom Tomcat im aktuellen Pfad suchen, auspacken und die nicht notwendigen Verzeichnisse löschen
LATEST=`ls -tp apache-tomcat-8.5*.tar.gz | grep -v /$ | head -1`
rm -rf tomcat
rm -rf tomcat.tar.gz
rm -rf tomcat-latest.tar.gz
ln -s $LATEST tomcat-latest.tar.gz
mkdir -p tomcat
tar xvzf tomcat-latest.tar.gz -C tomcat --strip-components=1
rm -rf tomcat/conf
rm -rf tomcat/temp
rm -rf tomcat/webapps
rm -rf tomcat/work

# Tomcat Native Library entpacken und an der richtigen Stelle platzieren
cp tomcat/bin/tomcat-native.tar.gz .
rm -rf tomcat-native
mkdir -p tomcat-native
tar xvzf tomcat-native.tar.gz -C tomcat-native --strip-components=1
cd tomcat-native/native/

# Check, wo ein passenden JDK liegt; ggf. Fehler schmeißen
if [ -d "/usr/lib/jvm/java-8-openjdk-amd64" ]; then
  MY_JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
elif [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then
  MY_JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
else
  echo "No JDK found"
  exit 1
fi

echo $MY_JAVA_HOME

# libapr kompilieren; die Installation vom Tomcat und libapr erfolgt mit einem separaten Skript
./configure --with-java-home=$MY_JAVA_HOME
make

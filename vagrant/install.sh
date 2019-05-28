

java_home_var=/app/java

if test -n "$1"
then
  java_home_var=$1 
fi    

echo java_home_var:$java_home_var

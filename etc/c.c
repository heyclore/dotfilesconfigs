#/*
main='c.c'
exe='exe.exe'
gcc $main -o /tmp/$exe
if [ $? -eq 0 ]; then
    /tmp/$exe
fi
exit 0
*/

#include <stdio.h>

int main() {

  printf("%s\n", "jancok asukabeh");
  return 0;
}

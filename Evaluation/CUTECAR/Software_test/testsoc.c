#include <sdio.h>
#include <string.h>

int main(void)
{
    char* msg = "hello world";
    FILE* fp;
    fp = fopen("xxx");
    if (fp)
    {
        fprintf(fp,"%s",msg);
        fclose(fp);
    }
    return 0;
}
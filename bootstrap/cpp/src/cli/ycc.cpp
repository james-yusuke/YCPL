#include "src/cli/driver.h"

int main(int argc, char *argv[])
{
    return ycpl::bootstrap_cli::run_ycc(argc, argv);
}

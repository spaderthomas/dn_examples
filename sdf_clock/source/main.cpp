#define DN_IMPLEMENTATION
#include "dn.hpp"

int main(int num_args, char** args) {
  dn_app_descriptor_t app = {
    .install_path = "../../sdf_clock",
    .engine_path = "../thirdparty/doublenickel",
    .write_path = "source/app/data",
    .app_path = "source/app",
  };
  dn_main(app);  
}
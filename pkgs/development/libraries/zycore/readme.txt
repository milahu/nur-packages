TODO fix CMakeLists.txt

CMake Error at /nix/store/ny0cljlv9dnbf6m123mlcr0n2v1bp08q-zycore-c-1.5.0/lib/cmake/zycore/zycore-config.cmake:13 (message):
  File or directory
  /nix/store/ny0cljlv9dnbf6m123mlcr0n2v1bp08q-zycore-c-1.5.0//nix/store/ny0cljlv9dnbf6m123mlcr0n2v1bp08q-zycore-c-1.5.0/include
  referenced by variable zycore_INCLUDE_DIR does not exist !
Call Stack (most recent call first):
  /nix/store/ny0cljlv9dnbf6m123mlcr0n2v1bp08q-zycore-c-1.5.0/lib/cmake/zycore/zycore-config.cmake:38 (set_and_check)
  CMakeLists.txt:109 (find_package)
  CMakeLists.txt:141 (locate_zycore)

zycore-config.cmake:38
set_and_check(zycore_INCLUDE_DIR "${PACKAGE_PREFIX_DIR}//nix/store/ny0cljlv9dnbf6m123mlcr0n2v1bp08q-zycore-c-1.5.0/include")
set_and_check(zycore_LIB_DIR "${PACKAGE_PREFIX_DIR}//nix/store/ny0cljlv9dnbf6m123mlcr0n2v1bp08q-zycore-c-1.5.0/lib")

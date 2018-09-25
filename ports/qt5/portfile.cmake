SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(VCPKG_LIBRARY_LINKAGE static)
if(PORT MATCHES "qt5-")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

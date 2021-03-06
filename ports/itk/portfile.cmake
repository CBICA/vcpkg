include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF v4.13.0
    SHA512 96a189aaa48f34db469ad1d1df8f7bf69d65e3bd43d7898562550938a6b7acbb324c2a5579e887c6d9f4b8940f3bf582d457ee44e8f83bdbb73c1c6a7c61a5ac
    HEAD_REF master
)

set(CMAKE_MODULE_PATH)

set(VCPKG_LIBRARY_LINKAGE static)
if(PORT MATCHES "qt5-")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

set(Module_ITKVtkGlue OFF)
set(Module_LesionSizingToolkit OFF)
if("vtk" IN_LIST FEATURES)
  list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/vtk)
  set(Module_ITKVtkGlue ON)
  set(Module_LesionSizingToolkit ON)
endif()

list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/dcmtk)

# directory path length needs to be shorter than 50 characters
set(ITK_BUILD_DIR ${CURRENT_BUILDTREES_DIR}/ITK)
if(EXISTS ${ITK_BUILD_DIR})
  file(REMOVE_RECURSE ${ITK_BUILD_DIR})
endif()
file(RENAME ${SOURCE_PATH} ${ITK_BUILD_DIR})
set(SOURCE_PATH "${ITK_BUILD_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DITK_USE_GIT_PROTOCOL=OFF
        -DITK_SKIP_PATH_LENGTH_CHECKS=ON
        -DDO_NOT_INSTALL_ITK_TEST_DRIVER=ON
        -DITK_INSTALL_DATA_DIR=share/itk/data
        -DITK_INSTALL_DOC_DIR=share/itk/doc
        -DITK_INSTALL_PACKAGE_DIR=share/itk
        -DITK_LEGACY_REMOVE=ON
        -DITK_FUTURE_LEGACY_REMOVE=ON
        -DITK_USE_64BITS_IDS=ON
        -DITK_USE_CONCEPT_CHECKING=ON
        #-DITK_USE_SYSTEM_LIBRARIES=ON # enables USE_SYSTEM for all third party libraries, some of which do not have vcpkg ports such as CastXML, SWIG, MINC etc
        -DITK_USE_SYSTEM_DOUBLECONVERSION=ON
        -DITK_USE_SYSTEM_EXPAT=ON
        -DITK_USE_SYSTEM_JPEG=ON
        -DITK_USE_SYSTEM_PNG=ON
        -DITK_USE_SYSTEM_TIFF=ON
        -DITK_USE_SYSTEM_ZLIB=ON
        -DITK_USE_SYSTEM_DCMTK=ON
        #-DITK_USE_SYSTEM_HDF5=ON
        -DITK_FORBID_DOWNLOADS=OFF
        -DVCL_INCLUDE_CXX_0X=ON 
        -DDCMTK_USE_ICU=OFF 
        -DModule_ITKReview=ON
        -DModule_SkullStrip=ON
        -DModule_TextureFeatures=ON
        -DModule_RLEImage=ON
        -DModule_IsotropicWavelets=ON
        -DModule_PrincipalComponentsAnalysis=ON
        -DModule_ITKDCMTK=ON
        -DModule_IOTransformDCMTK=ON
        -DModule_ITKIODCMTK=ON
        -DModule_ITKVideoBridgeOpenCV=ON
        -DModule_ITKVtkGlue=${Module_ITKVtkGlue}
        -DModule_LesionSizingToolkit=${Module_LesionSizingToolkit}
        # I havn't tried Python wrapping in vcpkg
        #-DITK_WRAP_PYTHON=ON
        #-DITK_PYTHON_VERSION=3

        # HDF5 must NOT be installed, otherwise it causes: ...\installed\x64-windows-static\include\H5Tpkg.h(25): fatal error C1189: #error:  "Do not include this file outside the H5T package!"
        -DITK_USE_SYSTEM_HDF5=OFF # if ON, causes: ...\buildtrees\itk\x64-windows-static-rel\Modules\ThirdParty\HDF5\src\itk_H5Cpp.h(25): fatal error C1083: Cannot open include file: 'H5Cpp.h': No such file or directory

        #-DModule_IOSTL=ON # example how to turn on a non-default module
        #-DModule_MorphologicalContourInterpolation=ON # example how to turn on a remote module
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets() # combines release and debug build configurations

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/itk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/itk/LICENSE ${CURRENT_PACKAGES_DIR}/share/itk/copyright)

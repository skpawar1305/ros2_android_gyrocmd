#!/bin/bash
set -eu

cd /home/user/workspace

sudo apt install python3-empy -y
sudo pip uninstall empy -y
export PYTHON3_EXEC="$( which python3 )"
export PYTHON3_LIBRARY="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
export PYTHON3_INCLUDE_DIR="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"

rm -rf src/ros2/rmw
git clone https://github.com/ros2/rmw.git -b galactic src/ros2/rmw

rm -rf src/ros2/rmw_fastrtps
git clone https://github.com/skpawar1305/rmw_fastrtps.git src/ros2/rmw_fastrtps

colcon build \
    --packages-ignore cyclonedds rcl_logging_log4cxx rcl_logging_spdlog rosidl_generator_py rclandroid ros2_talker_android ros2_listener_android \
    --cmake-args \
    -DPYTHON_EXECUTABLE=${PYTHON3_EXEC} \
    -DPYTHON_LIBRARY=${PYTHON3_LIBRARY} \
    -DPYTHON_INCLUDE_DIR=${PYTHON3_INCLUDE_DIR} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
    -DANDROID=ON \
    -DANDROID_FUNCTION_LEVEL_LINKING=OFF \
    -DANDROID_NATIVE_API_LEVEL=${ANDROID_TARGET} \
    -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME} \
    -DANDROID_STL=c++_shared \
    -DANDROID_ABI=${ANDROID_ABI} \
    -DANDROID_NDK=${ANDROID_NDK} \
    -DTHIRDPARTY=ON  \
    -DCOMPILE_EXAMPLES=OFF \
    -DCMAKE_FIND_ROOT_PATH="${PWD}/install" \
    -DBUILD_TESTING=OFF \
    -DRCL_LOGGING_IMPLEMENTATION=rcl_logging_noop

## copy libc++_shared.so
cp /opt/android/android-ndk-r23b/sources/cxx-stl/llvm-libc++/libs/${ANDROID_ABI}/libc++_shared.so /home/user/workspace
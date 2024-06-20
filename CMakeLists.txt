cmake_minimum_required(VERSION 3.8)
project(rclcpp_dlclose_segfault)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(rclcpp REQUIRED)

add_library(ros_segfault_min_lib SHARED
  src/ros_segfault_min_lib.cc
)
target_link_libraries(ros_segfault_min_lib rclcpp::rclcpp)
# Direct.
add_executable(ros_segfault_min_direct src/ros_segfault_min_direct.cc)
target_link_libraries(ros_segfault_min_direct ros_segfault_min_lib)
# dlopen()
add_executable(ros_segfault_min_dlopen src/ros_segfault_min_dlopen.cc)

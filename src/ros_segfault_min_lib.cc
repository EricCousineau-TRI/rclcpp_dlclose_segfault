#include "ros_segfault_min_lib.h"

#include <rclcpp/rclcpp.hpp>

namespace {

void RclcppInit() {
  const int argc = 0;
  const char** argv = nullptr;
  const rclcpp::InitOptions init_options{};
  const rclcpp::SignalHandlerOptions signal_handler_options =
      rclcpp::SignalHandlerOptions::None;
  return rclcpp::init(argc, argv, init_options, signal_handler_options);
}

}  // namespace

extern "C" {

void InitNode() {
  RclcppInit();
  rclcpp::Node("node");
}

void InitAndLeakNode() {
  RclcppInit();
  new rclcpp::Node("node");
}

}  // extern "C"

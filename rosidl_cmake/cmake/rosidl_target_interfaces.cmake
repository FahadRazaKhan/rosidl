# Copyright 2015 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Add the include directories and libraries from an interface generation target
# in the current project and a specific type support to another target.
#
# It also adds target dependencies to `target` to ensure the interface
# generation happens before.
#
# It can have an optional scope keyword (PRIVATE | PUBLIC | INTERFACE) as a second argument.
#
# :param target: the target name
# :type target: string
# :param interface_target: the target name of generated interfaces
# :type interface_target: string
# :param typesupport_name: the package name of the type support
# :type typesupport_name: string
# :scope keyword(optional): PUBLIC | PRIVATE | INTERFACE
#
# @public
#
function(rosidl_target_interfaces target interface_target typesupport_name)
  message(
    DEPRECATION
      "Use rosidl_get_typesupport_target() and target_link_libraries() instead of rosidl_target_interfaces(). i.e:
  rosidl_get_typesupport_target(cpp_typesupport_target \"\${PROJECT_NAME}\" \"rosidl_typesupport_cpp\")
  target_link_libraries(\${PROJECT_NAME}_node \"\${cpp_typesupport_target}\")
")
  if(${ARGC} GREATER 4)
    list(SUBLIST ARGN 1 -1 REMAINING_ARGS)
    message(
      FATAL_ERROR
        "rosidl_target_interfaces() called with unused arguments: ${REMAINING_ARGS}"
    )
  endif()

  if(${ARGC} EQUAL 4)
    if("${ARGV1}" STREQUAL "PUBLIC")
      set(optional_keyword "${ARGV1}")
    elseif("${ARGV1}" STREQUAL "PRIVATE")
      set(optional_keyword "${ARGV1}")
    elseif("${ARGV1}" STREQUAL "INTERFACE")
      set(optional_keyword "${ARGV1}")
    else()
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the second argument must be a scope keyword PRIVATE|PUBLIC|INTERFACE"
      )
    endif()

    if(NOT TARGET ${ARGV0})
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the first argument '${ARGV0}' must be a valid target name"
      )
    endif()
    if(NOT TARGET ${ARGV2})
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the third argument '${ARGV2}' must be a valid target name"
      )
    endif()
    set(typesupport_target "${ARGV2}__${ARGV3}")
    if(NOT TARGET ${typesupport_target})
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the third argument '${ARGV2}' "
          "concatenated with the fourth argument '${ARGV3}' "
          "using double underscores must be a valid target name")
    endif()

    add_dependencies(${ARGV0} ${ARGV2})
    get_target_property(include_directories ${typesupport_target}
                        INTERFACE_INCLUDE_DIRECTORIES)
    if(include_directories)
      target_include_directories(${ARGV0} PUBLIC ${include_directories})
    endif()
    target_link_libraries(${ARGV0} ${optional_keyword} ${typesupport_target})

  else()

    if(NOT TARGET ${target})
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the first argument '${target}' must be a valid target name"
      )
    endif()
    if(NOT TARGET ${interface_target})
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the second argument '${interface_target}' must be a valid target name"
      )
    endif()
    set(typesupport_target "${interface_target}__${typesupport_name}")
    if(NOT TARGET ${typesupport_target})
      message(
        FATAL_ERROR
          "rosidl_target_interfaces() the second argument '${interface_target}' "
          "concatenated with the third argument '${typesupport_name}' "
          "using double underscores must be a valid target name")
    endif()

    add_dependencies(${target} ${interface_target})
    get_target_property(include_directories ${typesupport_target}
                        INTERFACE_INCLUDE_DIRECTORIES)
    if(include_directories)
      target_include_directories(${target} PUBLIC ${include_directories})
    endif()
    target_link_libraries(${target} ${typesupport_target})

  endif()
endfunction()

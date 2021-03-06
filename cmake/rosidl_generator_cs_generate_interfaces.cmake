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

set(rosidl_generate_interfaces_cs_IDL_FILES
  ${rosidl_generate_interfaces_IDL_FILES})
set(_output_path "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_cs/${PROJECT_NAME}")

set(_generated_msg_sources "")
set(_generated_srv_sources "")
set(_message_targets "")
foreach(_idl_file ${rosidl_generate_interfaces_cs_IDL_FILES})
  get_filename_component(_parent_folder "${_idl_file}" DIRECTORY)
  get_filename_component(_parent_folder "${_parent_folder}" NAME)
  get_filename_component(_msg_name "${_idl_file}" NAME_WE)
  get_filename_component(_extension "${_idl_file}" EXT)
  string_camel_case_to_lower_case_underscore("${_msg_name}" _header_name)
  set(MSG_TARGET_NAME "generate_cs_messages_${_msg_name}_${PROJECT_NAME}")


  if(_extension STREQUAL ".msg" OR _extension STREQUAL ".srv")
	if(BUILD_TESTING)
		if(NOT WIN32)
	  		add_custom_target(
	   			    "${MSG_TARGET_NAME}" ALL
	    			COMMAND mono ${rosidl_generator_cs_BIN} -m ${_idl_file} ${PROJECT_NAME} ${_output_path}
	    			COMMENT "Generating CS code for ${_msg_name}"
	    			VERBATIM
	  			)
	  			if(${PROJECT_NAME} STREQUAL "rosidl_generator_cs")
                   # add_dependencies(${MSG_TARGET_NAME} ros2cs_message_generator)
                endif()
	  			
		else()
			add_custom_target(
	   			    "${MSG_TARGET_NAME}"  ALL
	    			COMMAND ${rosidl_generator_cs_BIN} -m ${_idl_file} ${PROJECT_NAME} ${_output_path}
	    			COMMENT "Generating CS code for ${_msg_name}"
	    			VERBATIM
	  			)
		endif()
	list(APPEND _message_targets ${MSG_TARGET_NAME})
	else()
		if(NOT WIN32)
			add_custom_target(
	    			"${MSG_TARGET_NAME}"  ALL
	    			COMMAND mono ${rosidl_generator_cs_BIN} -m ${_idl_file} ${PROJECT_NAME} ${_output_path}
	    			COMMENT "Generating CS code for ${_msg_name}"
	    			VERBATIM
	  			)
		else()
			add_custom_target(
	    			"${MSG_TARGET_NAME}"  ALL
	    			COMMAND  ${rosidl_generator_cs_BIN} -m ${_idl_file} ${PROJECT_NAME} ${_output_path}
	    			COMMENT "Generating CS code for ${_msg_name}"
	    			VERBATIM
	  			)
		endif()
	  
	endif()
  else()
        list(REMOVE_ITEM rosidl_generate_interfaces_cs_IDL_FILES ${_idl_file})
  endif()
 
endforeach()

if(NOT WIN32)
add_custom_target(
    "compile_cs_messages" ALL
    COMMAND mono ${rosidl_generator_cs_BIN} -c ${_output_path} ${_output_path}/${PROJECT_NAME}.dll
    DEPENDS ${_message_targets}
    COMMENT "Compiling generated CS Code for ${PROJECT_NAME}"
    VERBATIM
 )
else()
add_custom_target(
    "compile_cs_messages" ALL
    COMMAND ${rosidl_generator_cs_BIN} -c ${_output_path} ${_output_path}/${PROJECT_NAME}.dll
    DEPENDS ${_message_targets}
    COMMENT "Compiling generated CS Code for ${PROJECT_NAME}"
    VERBATIM
 )
endif()

if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
	if(NOT WIN32)
  	install(
   	 	FILES 
		${_output_path}/${PROJECT_NAME}.dll 
		#$ENV{AMENT_PREFIX_PATH}/lib/rclcs.dll
    		DESTINATION 
		"lib/"
    	)
	else()
	install(
   	 	FILES 
		${_output_path}/${PROJECT_NAME}.dll 
		#$ENV{AMENT_PREFIX_PATH}/lib/rclcs.dll
    		DESTINATION 
		"bin/"
    	)
	endif()
endif()



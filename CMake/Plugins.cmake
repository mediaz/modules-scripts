function(add_folder_as_plugin_project NAME DEPENDENCIES INCLUDE_FOLDERS)
	project(${NAME})
	message("Processing plugin ${NAME}")

	set(SOURCE_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/Source")
	set(CONFIG_FOLDERS "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/Config")

	file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS ${SOURCE_FOLDER}
		"${SOURCE_FOLDER}/*.cpp" "${SOURCE_FOLDER}/*.inl" "${SOURCE_FOLDER}/*.glsl" "${SOURCE_FOLDER}/*.hlsl"
		"${SOURCE_FOLDER}/*.comp" "${SOURCE_FOLDER}/*.frag" "${SOURCE_FOLDER}/*.vert"
		"${SOURCE_FOLDER}/*.py")
	list(APPEND CONFIG_FILES)

	foreach(CONFIG_FOLDER ${CONFIG_FOLDERS})
		file(GLOB_RECURSE CUR_CONFIG_FILES CONFIGURE_DEPENDS ${CONFIG_FOLDER}
			"${CONFIG_FOLDER}/*.noscfg" "${CONFIG_FOLDER}/*.nosdef" "${CONFIG_FOLDER}/*.fbs")
		list(APPEND CONFIG_FILES ${CUR_CONFIG_FILES})
	endforeach()

	file(GLOB_RECURSE HEADERS CONFIGURE_DEPENDS ${SOURCE_FOLDER} "${SOURCE_FOLDER}/*.h" "${SOURCE_FOLDER}/*.hpp")
	file(GLOB_RECURSE RESOURCES CONFIGURE_DEPENDS ${SOURCE_FOLDER} "${SOURCE_FOLDER}/*.rc")

	set(SHADER_FOLDERS "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/Shaders")
	list(APPEND SHADERS)

	foreach(SHADER_FOLDER ${SHADER_FOLDERS})
		file(GLOB_RECURSE CUR_SHADERS CONFIGURE_DEPENDS ${SHADER_FOLDER}
			"${SHADER_FOLDER}/*.glsl" "${SHADER_FOLDER}/*.comp" "${SHADER_FOLDER}/*.frag" "${SHADER_FOLDER}/*.vert")
		list(APPEND SHADERS ${CUR_SHADERS})
	endforeach()

	add_library(${NAME} MODULE ${SOURCES} ${SHADERS} ${HEADERS} ${RESOURCES} ${CONFIG_FILES})
	set_target_properties(${NAME} PROPERTIES
		CXX_STANDARD 20
		LIBRARY_OUTPUT_DIRECTORY_DEBUG "${CMAKE_CURRENT_SOURCE_DIR}/Binaries"
		LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_CURRENT_SOURCE_DIR}/Binaries"
		LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_CURRENT_SOURCE_DIR}/Binaries"
		LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_CURRENT_SOURCE_DIR}/Binaries"
	)

	foreach(source IN LISTS SOURCES)
		get_filename_component(source_path "${source}" PATH)
		string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "" source_path_compact "${source_path}")
		string(REPLACE "/" "\\" source_path_msvc "${source_path_compact}")
		source_group("${source_path_msvc}" FILES "${source}")
	endforeach()

	foreach(header IN LISTS HEADERS)
		get_filename_component(header_path "${header}" PATH)
		string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "" header_path_compact "${header_path}")
		string(REPLACE "/" "\\" header_path_msvc "${header_path_compact}")
		source_group("${header_path_msvc}" FILES "${header}")
	endforeach()

	target_include_directories(${NAME} PRIVATE ${INCLUDE_FOLDERS})

	target_link_libraries(${NAME} PRIVATE ${DEPENDENCIES})
	target_link_libraries(${NAME} PUBLIC nosPluginSDK)
endfunction()

# Nodos Plugin SDK
if (NOT WITH_NODOS)
	cmake_path(SET NODOS_SDK_DIR_PATH $ENV{NODOS_SDK_DIR})
	list(APPEND CMAKE_MODULE_PATH ${NODOS_SDK_DIR_PATH}/cmake)
    find_package(nosPluginSDK REQUIRED)
endif()
cmake_minimum_required(VERSION 3.16)

project(QuickDict VERSION 0.2 LANGUAGES CXX)

add_subdirectory(QuickDict)
add_subdirectory(third_party)

install(TARGETS QuickDict DESTINATION ${CMAKE_INSTALL_BINDIR})
if(NOT APPLE)
    message(STATUS "dir: ${CMAKE_INSTALL_DATADIR}/QuickDict/ ${CMAKE_INSTALL_DATAROOTDIR} ${DATAROOT}")
	install(FILES ${PROJECT_SOURCE_DIR}/LICENSE
		# DESTINATION ${CMAKE_INSTALL_DATADIR}/QuickDict/)
        TYPE DATA)
	# install(FILES nvim-qt.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
    install(FILES ${PROJECT_SOURCE_DIR}/dist/QuickDict.desktop DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications)
    install(FILES ${PROJECT_SOURCE_DIR}/dist/QuickDict.png DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/512x512/apps)
    install(FILES ${PROJECT_SOURCE_DIR}/resources/images/QuickDict-32x32.png
			RENAME QuickDict.png
			# DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/32x32/apps/)
			DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps)
endif()

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(CPackOptions)

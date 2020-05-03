CMAKE_MINIMUM_REQUIRED (VERSION 3.17)

PROJECT (ProjectName)

FIND_PACKAGE (Boost 1.72 REQUIRED COMPONENTS component)

ADD_LIBRARY (
    project
    "./src/main.cpp"
)

TARGET_LINK_LIBRARIES (
    project
    Boost::component
)

TARGET_INCLUDE_DIRECTORIES (
    project
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
)

SET_TARGET_PROPERTIES (
    project
    PROPERTIES CXX_STANDARD 17
)

IF (PROJECT_ENABLE_TEST)
    FIND_PACKAGE (Boost 1.72 REQUIRED COMPONENTS unit_test_framework)
    ADD_EXECUTABLE (
        project-test
        "./test/project_test.cpp"
        "./test/test.cpp"
    )
    SET_TARGET_PROPERTIES (
        project-test
        PROPERTIES CXX_STANDARD 17
    )
    TARGET_COMPILE_OPTIONS (
        project
        PRIVATE -fprofile-instr-generate
        PRIVATE -fcoverage-mapping
    )
    TARGET_COMPILE_OPTIONS (
        project-test
        PRIVATE -fprofile-instr-generate
        PRIVATE -fcoverage-mapping
    )
    TARGET_LINK_OPTIONS (
        project
        PRIVATE -fprofile-instr-generate
    )
    TARGET_LINK_OPTIONS (
        project-test
        PRIVATE -fprofile-instr-generate
    )
    TARGET_COMPILE_DEFINITIONS (
        project-test
        PRIVATE BOOST_TEST_DYN_LINK)
    TARGET_LINK_LIBRARIES (
        project-test
        Boost::component
        project
    )
    ADD_CUSTOM_TARGET (
        project-coverage
        COMMAND
            ${CMAKE_COMMAND} -E
                env LLVM_PROFILE_FILE=$<TARGET_FILE_DIR:project-test>/$<TARGET_FILE_BASE_NAME:project-test>.profraw
                $<TARGET_FILE:project-test>
        COMMAND
            llvm-profdata merge
                --sparse
                --output $<TARGET_FILE_DIR:project-test>/$<TARGET_FILE_BASE_NAME:project-test>.profdata
                $<TARGET_FILE_DIR:project-test>/$<TARGET_FILE_BASE_NAME:project-test>.profraw
        COMMAND
            llvm-cov show
                --format html
                --instr-profile $<TARGET_FILE_DIR:project-test>/$<TARGET_FILE_BASE_NAME:project-test>.profdata
                --output-dir "${PROJECT_SOURCE_DIR}/coverage"
                $<TARGET_FILE:project-test>
        DEPENDS project-test
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")
ENDIF (PROJECT_ENABLE_TEST)

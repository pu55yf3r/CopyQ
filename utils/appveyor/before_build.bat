@echo on

%QTDIR%\bin\qmake --version

set KF5_FULLVER=%KF5_VERSION%.%KF5_PATCH%
set INSTALL_PREFIX=%cd%\usr\kf-%KF5_FULLVER%-%CMAKE_GENERATOR_ARCH%
set CMAKE_PREFIX=%INSTALL_PREFIX%\lib\cmake
set CMAKE_PREFIX_PATH=%CMAKE_PREFIX%;%INSTALL_PREFIX%\share\ECM\cmake
mkdir %INSTALL_PREFIX%

set PATH=%PATH%;%INSTALL_PREFIX%\bin

mkdir dependencies
cd dependencies || goto :error

if not exist %CMAKE_PREFIX%\libsnoretoast call :snoretoast_build
if not exist %INSTALL_PREFIX%\share\ECM call :kf5_build extra-cmake-modules
if not exist %CMAKE_PREFIX%\KF5Config call :kf5_build kconfig
if not exist %CMAKE_PREFIX%\KF5WindowSystem call :kf5_build kwindowsystem
if not exist %CMAKE_PREFIX%\KF5CoreAddons call :kf5_build kcoreaddons
if not exist %CMAKE_PREFIX%\KF5Notifications call :kf5_build knotifications

REM appveyor PushArtifact "%cd%\..\build\knotifications\CMakeFiles\CMakeError.log"
REM appveyor PushArtifact "%cd%\..\build\knotifications\CMakeFiles\CMakeOutput.log"

cd ..

cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release^
 -G "%CMAKE_GENERATOR%" -A "%CMAKE_GENERATOR_ARCH%"^
 -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%"^
 -DWITH_TESTS=ON || goto :error

:error
exit /b %errorlevel%

:snoretoast_build
    set bin=snoretoast-v%SNORETOAST_VERSION%
    curl -LO https://invent.kde.org/libraries/snoretoast/-/archive/v%SNORETOAST_VERSION%/%bin%.zip || goto :error
    cmake -E tar xf %bin%.zip --format=zip || goto :error

    cd %bin% || goto :error

    cmake -H. -B../build/%bin% -DCMAKE_BUILD_TYPE=Release^
     -G "%CMAKE_GENERATOR%" -A "%CMAKE_GENERATOR_ARCH%"^
     -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%"^
     -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" || goto :error

    cmake --build ../build/%bin% --config Release --target install || goto :error

    cd ..
goto:eof

:kf5_build
    curl -LO https://download.kde.org/stable/frameworks/%KF5_VERSION%/%~1-%KF5_FULLVER%.zip || goto :error

    cmake -E tar xf %~1-%KF5_FULLVER%.zip --format=zip

    cd %~1-%KF5_FULLVER% || goto :error

    for %%p in (%APPVEYOR_BUILD_FOLDER%\utils\appveyor\patches\%~1\*.patch) do call :apply_patch %%p || goto :error

    cmake -H. -B../build/%~1 -DCMAKE_BUILD_TYPE=Release^
     -G "%CMAKE_GENERATOR%" -A "%CMAKE_GENERATOR_ARCH%"^
     -DKCONFIG_USE_GUI=OFF^
     -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%"^
     -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" || goto :error

    cmake --build ../build/%~1 --config Release --target install || goto :error

    cd ..
goto:eof

:apply_patch
    C:\msys64\usr\bin\patch -p1 < %~1 || goto :error
goto:eof

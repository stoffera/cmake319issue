## Setup Xcode project

```sh
$ mkdir build && cd $_
$ cmake .. -G Xcode
```

Open the XCode project (`open LinkDemo.xcodeproj`)

## Compile in Xcode

1. First remember that you should set a *code signing team*. (Compilation fails if *None* is selected.)
2. Select the build scheme: *Any iOS Device (arm64)* from the drop down menu in the toolbar.
3. Hit `Cmd + B` to build the project - it should succeed.
4. Now, select the scheme "*iPhone ... (Simulator)*" (Any sdevice simulator will do.)
5. Hit `Cmd + B` to build for the simulator - linking will fail.

## Cause

Upon project generation CMake injector the absolute paths for the system libraries *Foundation* and *Core Graphics* into the build setting *Other Linker Flags* (`OTHER_LDFLAGS`):

* `-F /path/to/native/iphone/libs`
* `-f Foundation`
* `-F /path/to/native/iphone/libs` 
* `-f CoreGraphics`

Since these libraries are *arm64* only, the linker will ignore them, when building for *x86_64* simulator.

Therefore, linking cannot find any of the symbols defined by either *Foundation* or *Core Graphics*.

## Tried workarounds

I have explorered there possible workaround:

#### 1. Using `CMAKE_XCODE_LINK_BUILD_PHASE_MODE`

Setting the variable `CMAKE_XCODE_LINK_BUILD_PHASE_MODE` to `KNOWN_LOCATION` removes only some of the linker settings from `OTHER_LDFLAGS` - the critical one `-F /path/to/native/iphone/libs` remains!

#### 2. Using `CMAKE_OSX_SDKROOT`

During the generator step we can determine where the `find_library` looks for the libraries with:

```sh
$ cmake .. -DCMAKE_OSX_SDKROOT=iphonesimulator -G Xcode
```
This change the `-F` linker setting to: `/path/to/simulator/libs` 

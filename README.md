# Demo of CMake 3.19's XCode generator sdkroot issue

**Steps to reproduce:**

## Setup Xcode project

```sh
$ mkdir build && cd $_
$ cmake .. -G Xcode
```

Open the XCode project (`open LinkDemo.xcodeproj`)

## Compile in Xcode

1. First remember that you should set a *code signing team*. (Compilation fails if *None* is selected.)
2. Select the *Demo* target and build scheme: *Any iOS Device (arm64)*, from the drop down menu in the toolbar.
3. Hit `Cmd + B` to build the project - it should succeed.
4. Now, choose a "*iPhone ... (Simulator)*" scheme (Any simulated device will do.)
5. Hit `Cmd + B` to build for the simulator - linking will fail.

## Cause

Upon project generation CMake injects the absolute paths for the system libraries *Foundation* and *Core Graphics* into the build setting *Other Linker Flags* (`OTHER_LDFLAGS`):

* `-F /path/to/native/iphone/libs`
* `-f Foundation`
* `-F /path/to/native/iphone/libs` 
* `-f CoreGraphics`

(You can see this in the targets *Build Settings*.)

Since these iPhone libraries are *arm64* only, the linker will ignore them, when building for *x86_64* simulator on Intel Macs.

On Apple Silicon Macs, the linker will fail with this error message: "*building for iOS Simulator, but linking in .tbd built for iOS, file*".

## Tried workarounds

I have explorered these possible workaround:

### 1. Using `CMAKE_XCODE_LINK_BUILD_PHASE_MODE`

Setting the variable `CMAKE_XCODE_LINK_BUILD_PHASE_MODE` to `KNOWN_LOCATION` removes the linker settings from `OTHER_LDFLAGS`.

However, now the *Framework Search Path* setting (`FRAMEWORK_SEARCH_PATHS`) is set to `/path/to/native/iphone/libs`. So the issue still remains!

### 2. Using `CMAKE_OSX_SYSROOT`

During the generator step we can determine where the `find_library` looks for the libraries with:

```sh
$ cmake .. -CMAKE_OSX_SYSROOT=iphonesimulator -G Xcode
```

This change the `-F` linker setting to: `/path/to/simulator/libs`. Now our project will work for the Simulator - but *not* for native iOS devices!

Even if this workaround enables us to built for the two different schemes, we have to choose a scheme in the generation step. In a single Xcode project you can still not change the build scheme, from one to another.

### 3. Setting `XCODE_ATTRIBUTE_FRAMEWORK_SEARCH_PATHS`

I tried forcing the Xcode setting `FRAMEWORK_SEARCH_PATHS` using the `XCODE_ATTRIBUTE_<an-attribute>` target property.

I added this target property statement:

```cmake
set_target_properties(Demo PROPERTIES
    XCODE_ATTRIBUTE_FRAMEWORK_SEARCH_PATHS "\$(inherited)"
)
```

(Setting an empty string or white space, has no effect.)

This just adds the `$(inherited)` variable to *Framework Search Path*, but the iPhoneOS is still appended. So no solution.

## How it worked in CMake 3.18

In previous CMake version, the `-F` flag was not included in *Other Linker Flags*. This meant Xcode had to decide what location to use, meaning changing the *build scheme* worked. The same Xcode project could build native and simulator schemes.

On the command line you were able to set the sdk root and build both:

```
$ cmake --build . --target Demo -- -sdk iphoneos14.4
$ cmake --build . --target Demo -- -sdk iphonesimulator14.4
```

# WritePad® Handwriting Recognition SDK
### For Android, iOS, Windows, Windows Phone, Xamarin

**Accurate, fast, compact, easy to use, multilingual, multiplatform handwriting recognition technology for mobile and desktop computers**

#### Copyright © 1997-2016 PhatWare® Corp. All rights reserved.

## License Overview

**You can:**

-   Install WritePad SDK on your computer and use it for personal and
    evaluation purposes only

**You cannot:**

-   Use WritePad SDK for any commercial purposes without obtaining the
    commercial license from [PhatWare Corp](http://www.phatware.com).
-   Redistribute your apps and/or any derivative works containing any
    portion of WritePad SDK without obtaining the commercial license
    from [PhatWare Corp](http://www.phatware.com).
-   Modify or reverse engineer WritePad SDK binary code (static
    library) and dictionaries without a written authorization from
    [PhatWare Corp](http://www.phatware.com).

For additional information, please read the [WritePad SDK developer license agreement](LICENSE.md).

To obtain commercial license, please contact PhatWare Corp. by sending
your request to [developer@phatware.com](mailto:developer@phatware.com)

## SDK Overview

WritePad® is a natural, style, writer and lexicon independent
multilingual handwriting recognition technology. WritePad SDK enables
natural handwriting input in third party applications on pen and/or
touch enabled mobile devices. The SDK includes:

-   WritePad handwriting recognition engine in object code and
    dictionaries support following languages **English (UK and US), French, German, Dutch, Danish, Indonesian, Italian,
    Portuguese (Brazilian and European), Norwegian, Finish, Swedish, and Spanish**.
    Engine is compatible with the user-specified platform. 
-   **iOS**: WritePad SDK static library supports iOS 6.0 or later. The sample code is for iOS
    9 or later and requires Xcode 7.0 or later.
-   **Android**: WritePad SDK static libraries support Android 4.0 or later for arm64-v8a, armeabi, armeabi-v7a, 
    mips, mips64, x86, and x86_64 CPUs. 
-   **Windows**: WritePad SDK DLLs for Windows and Windows Phone (x86, x64, and ARM CPUs), metro-style 
    (Windows/Windows Phone 8.1+), and desktop C# WPF sample (Windows 10+, .NET framework 4.6). Sample
    code requires Visual Studio 2015 Community Edition or higher.
-   **Xamarin (Android and iOS)**: WritePad SDK static libraries support Android 4.0 or later for arm64-v8a, armeabi, armeabi-v7a, 
    mips, mips64, x86, and x86_64 CPUs and static library supports iOS 6.0 or later. Samples for Android and iOS.
    Requires Xamarin Studio 5.0 or later Indie or Business edition.
-   Header files with definition of API calls and structures
-   Developer's Guide in PDF
-   Sample source code that demonstrates how to use the WritePad SDK
    in an iOS application.

## WritePad SDK features

-   Recognizes natural handwritten text in a variety of handwriting
    styles: *cursive (script),* **PRINT**, and MIX*ed*
    (*cursive*/print).
-   Recognizes dictionary words from its main or user-defined
    dictionary, as well as non-dictionary words, such as names, numbers
    and mixed alphanumeric combinations.
-   Provides automatic segmentation of handwritten text into words and
    automatically differentiates between vocabulary and non-vocabulary
    words, and between words and arbitrary alphanumeric strings
-   Does not require a user to train the software and allows for most
    users to achieve high accuracy right "out of the box".
-   Reliably recognizes handwriting in 12 languages, including English
    (US, UK), French, Finnish, German, Italian, Indonesian, Dutch,
    Danish, Norwegian, Portuguese (Brazil and Portugal), Swedish, and
    Spanish languages.

## Directory structure (iOS)

-   **Dictionaries** – contains WritePad dictionaries for all
    supported languages
-   **include** – contain SDK header files (C API)
-   **Library**– contains WritePad universal static libraries compiled
    for the device and emulator, including support for 32- and 64-bit.
-   **WritePadSDK-Sample** – sample project in Objective-C that
    demonstrates usage of the SDK. This project targets iOS SDK 8.0 or
    later, however, the handwriting recognition library can support
    older versions of iOS.
-   **WritePadSDK-Sample-Swift** – sample project demonstrating how to
    use WritePad SDK in iOS application written in Swift. Handwriting
    recognition manager in Objective-C provides bridge between WritePad
    C-language API and front end written in Swift.

## Directory structure (Android)

-   **dictionaries** – contains WritePad dictionaries for all
    supported languages
-   **include** – contain SDK header files (C API)
-   **libs**– contains WritePad static native Android libraries compiled for 
    arm64-v8a, armeabi, armeabi-v7a, mips, mips64, x86, and x86_64 CPUs
-   **sample_astudio** – WritePad SDK sample project for Android Studio 1.1+.

## Directory structure (Windows)

-   **Dictionaries** – contains WritePad dictionaries for all supported languages
-   **WinRT_CPPLayer** - contains the intermediate C++ library that should be used by managed applications.
-   **Windows_CPPLayer** - contains the intermediate C++ library that should be used by desktop applications.
-   **lib-windows-metro** - contains WritePad static libraries compiled for ARM, x86 and x64 CPU's, 
    for use by metro-style applications.
-   **lib-windows** - contains WritePad static libraries compiled for x86 and x64 CPU's, for use by desktop applications.
-   **WritePad_CSharpSample** - sample C#/XAML metro-style project that demonstrates usage of the SDK.
-   **WritePad_WPFSample** - sample WPF desktop application that demonstrates usage of the SDK.
-   **WritePad_WinFormsSample** – sample Windows Forms application that demonstrates usage of the SDK.

## Directory structure (Xamarin)

-   **Dictionaries** – contains WritePad dictionaries for all supported languages.
-   **include** – contain SDK C/C++ header files (not required for Xamarin, but useful as API reference).
-   **WritePadSDKiOSSample** – C# sample project that demonstrates how to use WritePad SDK on iOS platform.
-   **WritePadSDKAndroidSample** – C# sample project that demonstrates how to use WritePad SDK on Android platform.

## Compiling the sample project (iOS)

**WritePadSDK-Sample** and **WritePadSDK-Sample-Swift** sample projects
are included with the SDK targeting both iPad and iPhone devices. 

When creating your own project using the WritePad SDK which does not
contain any C or C++ files you may need to specify the additional linker
flags in the project settings (*Other Linker Flags* filed): **-cclib
-lstdc++**

You can use the sample source code in your project when integrating with
WritePad SDK. The sample source code is provided “AS-IS” without any
warranties. For more information, see the license and warranty
disclaimer at the beginning of each source file.

## Compiling the sample project (Android)

-   Start Android Studio 1.1 or later
-   Choose *Open an existing Android Studio project* and naviage to **\<sdk_path\>/Android/sample_astudio** folder
-   Choose Build/Make Project menu command
-   Run sample app on device or emulator

## Compiling the sample project (Windows)

You should first compile the included *WinRT\_CPPLayer* project for the chosen CPU in Release mode. Then 
you can compile the WritePad\_CSharpSample project on the same CPU architecture in Release mode and run it.

To compile the WPF sample or Windows Forms sample, you should first compile the included *Windows\_CPPLayer* 
project for the chosen CPU in Release mode. Then you can compile the *WritePad\_WPFSample* or 
*WritePad\_WinFormsSample* project on the same CPU architecture in Release mode and run it.

You need **Visual Studio 2015** (any edition) to compile and run the included samples.
You can use the sample source code in your project when integrating with WritePad SDK. 
The sample source code is provided "AS-IS" without any warranties. For more information, see the 
license and warranty disclaimer at the beginning of each source file.

## Compiling the sample project (Xamarin)

-   **WritePadSDKiOSSample** sample project is included with the SDK. This is a universal app, which 
    targets iPad and iPhone devices, however for handwriting recognition demonstration purposes, 
    we recommend to try it on iPad due to the larger screen size. 

    1.	Locate the WritePadSDKiOSSample.sln file in the WritePadSDKiOSSample folder and open with Xamarin Studio.
    2.	Build the project and execute on the device or emulator.
    3.	When application starts, write one or more words in the selected language (English is set by default) 
        horizontally on the yellow pad, and then press the Recognize button to convert to text. You can also 
        use the Return gesture (see documentation for description of gestures).  

-   **WritePadSDKAndroidSample** sample project for Android OS is also included with the SDK.
 
    1.	Locate the XamarinSDKSample.sln file in the WritePadSDKAndroidSample folder and open with Xamarin Studio.
    2.	Build the project and execute on the device or emulator.
    3.	When application starts, write one or more words in the selected language 
        (English is set by default) horizontally on the yellow pad, and then press the Recognize 
        button to convert to text. You can also use the Return gesture (see documentation for description of gestures).

**Note:** the handwriting recognition library is a native library with standard C APIs. You can access any of C function from the library directly from C# very similarly on either platform. For example:  

-   **on iOS:**
    
    ```C#
    [DllImport("__Internal", EntryPoint = "HWR_GetResultWord")]
    private static extern IntPtr HWR_GetResultWord( IntPtr reco, int nWord, int nAlternative ); 

    public static String recoResultWord(int column, int row) { 
        return Marshal.PtrToStringUni(HWR_GetResultWord(recoHandle, column, row)); 
    }
    ```
    
-   **on Android:** 
    
    ```C#
    [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetResultWord")] 
    private static extern IntPtr HWR_GetResultWord(IntPtr reco, int nWord, int nAlternative);

    public static String recoResultWord(int column, int row) { 
        return Marshal.PtrToStringUni(HWR_GetResultWord(recoHandle, column, row)); 
    }
    ```


**Please note that a use the SDK sample code, or any portion of it, in
an application that is not integrated with the WritePad SDK is 
prohibited and will constitute violation of the WritePad SDK License
Agreement**. 

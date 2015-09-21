# WritePadSDK
**WritePad Handwriting Recognition SDK
**

**License Overview
**

**You can:**

-   Install WritePad SDK on your computer and use it for personal and
    evaluation purposes only

**You cannot:**

-   Use WritePad SDK for commercial purposes without obtaining the
    commercial license from PhatWare Corp.
-   Redistribute your apps or any derivative works containing any
    portion of WritePad SDK without obtaining the commercial license
    from PhatWare Corp.
-   Modify or reverse engineer WritePad SDK binary code (static
    library) and dictionaries without written authorization from
    PhatWare Corp.

For additional information, please read the WritePad SDK developer
license agreement.

To obtain commercial license, please contact PhatWare Corp. by sending
your request to [developer@phatware.com](mailto:developer@phatware.com)

**Overview
**

WritePad® is a natural, style, writer and lexicon independent
multilingual handwriting recognition technology. WritePad SDK enables
natural handwriting input in third party applications on pen and/or
touch enabled mobile devices. The SDK includes:

-   WritePad handwriting recognition engine in object code and
    dictionaries for English, French, German, Dutch, Danish, Italian,
    Portuguese, Norwegian, Finish, Swedish, and Spanish languages.
    Engine is compatible with the user-specified platform. WritePad SDK
    static library supports iOS 6.0 or later (the sample code is for iOS
    9 or later and requires Xcode 7.0 or later).
-   Header files with definition of API calls and structures
-   Developer's Guide in PDF
-   Sample source code that demonstrates how to use the WritePad SDK
    in an iOS application.

**WritePad SDK features
**

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

**Directory structure
**

-   **Dictionaries** – contains WritePad dictionaries for all
    supported languages
-   **Documentation** – contains WritePad SDK documentation and
    licensing agreements
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

**Compiling the sample project
**

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

**Please note that a use the SDK sample code, or any portion of it, in
an application that is not integrated with the WritePad SDK is stickily
prohibited and will constitute violation of the WritePad SDK License
Agreement**. 




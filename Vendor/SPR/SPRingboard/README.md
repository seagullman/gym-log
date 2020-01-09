SPRingboard
===========

_(I see what you did there!)_

SPRingboard is a collection of reusable software components created by SPR to
accelerate mobile application development. It is divided into `Core` components
and `iOS` components. In the future, it may also have `tvOS` and `watchOS`
components. 

`Core` components only rely on Swift's core libraries: Foundation, libdispatch,
and XCTest. For more information about the Core components, see the README file 
in the `Core/` directory. 

`iOS` components make use of UIKit and other platform frameworks. Additionally,
the code under `iOS` may define extensions to standard Swift object types and 
Core components that provide functionality specifically for iOS apps. For 
more information about the iOS components, see the README file in the `iOS/` 
directory. 


Using in a Project
------------------

Follow the steps in this section to use SPRingboard in your iOS project. 

### Prerequisites

- The project must have an Xcode workspace (a `.xcworkspace` file). For SPR 
  projects, this is generally created by CocoaPods.
- Permission to READ the `sprconsulting/springboard-swift` Bitbucket 
  repository. While SPRingboard is available under an open source license, SPR 
  does not want to maintain a public open source project and has therefore 
  chosen to keep the repository private for the foreseeable future. 

### Instructions

The instructions have been detailed in many little steps and therefore looks 
intricate, but it takes less than 30 seconds when you have practiced it a few 
times. 

1.  Close Xcode.

2.  Add the SPRingboard source code and Xcode project files to your repository. 
    1. In the terminal at the root of your project's repository, run:

            git archive \
              --remote git@bitbucket.org:sprconsulting/springboard-swift.git \
              --format=tar \
              --prefix=Vendor/SPR/SPRingboard/ \
              master \
              | tar xf -

3.  Add the SPRingboard project to your app's Xcode workspace:
    1. Open your application's Xcode workspace.
    2.  In the Project Navigator (⌘⇧J), click the + in the bottom left
    3.  Select: Add Files to "Project"… (where "Project" is the name of your 
        project).
    4.  Navigate into the "Vendor" folder, "SPR" folder, then "SPRingboard" 
        folder. 
    5.  Select the "SPRingboard.xcodeproj" file.
    6.  Click the "Add" button.

4.  Add the SPRingboard framework as an embedded binary for your app:
    1.  In the Project Navigator (⌘⇧J), select _your app's_ Xcode project.
    2.  Select the target for your app; i.e., _not_ the Tests target.
    3.  In the "General" tab, find the "Embedded Binaries" section.
    4.  Click the + button
    5.  Select "SPRingboard" > "Products" > `SPRingboard.framework` iOS
    6.  Click the "Add" button

Done! When you want to use SPRingboard components in a file, add an `import` statement for the module, just like you do for Foundation or UIKit:

    import SPRingboard


Updating SPRingboard in a Project
---------------------------------

1.  Close Xcode.

2.  Remove the existing SPRingboard source code:
    1. In the terminal at the root of your project's repository, run:

            rm -Rf Vendor/SPR/SPRingboard/

3.  Add the latest SPRingboard source code and Xcode project files to your 
    repository. 
    1. In the terminal at the root of your project's repository, run:

            git archive \
              --remote git@bitbucket.org:sprconsulting/springboard-swift.git \
              --format=tar \
              --prefix=Vendor/SPR/SPRingboard/ \
              master \
              | tar xf -


Guiding Principles
------------------

When deciding whether to use an existing open source library or build a 
solution into SPRingboard, SPR must balance the short-term benefits and the 
long-term risks of using each library. During this analysis, SPR is guided by 
the following principles: 

1.  Any open source library that SPR uses in a project becomes SPR's 
    responsibility to support and maintain, just like the code that SPR writes 
    directly for the project. Consequently:
    - A senior engineer or architect must review the source code and be 
      comfortable debugging it and maintaining it across upcoming versions of 
      Swift and the underlying platform if the library is abandoned or slow to 
      update. 
    - Popular libraries with a history of community involvement and maintenance
      are preferred to obscure libraries or new libraries that have not 
      established a record of regular updates and maintenance. 
    - Libraries with significant automated testing are preferred over libraries
      that lack automated tests. 

2.  Libraries licensed in a manner that requires modifications or derivative 
    work to be released under the same license are prohibited. 
    - The preferred licenses are: public domain, BSD, MIT, ISC, Apache 2.0. 
      Anything else must be reviewed by the an SPR architect and approved by 
      the client. 


License
-------

The copyright to SPRingboard is owned by SPRI, LLC (i.e., "SPR Consulting").
SPRingboard is open source software, licensed under the terms of the MIT
license. See the `LICENSE` file for more information.


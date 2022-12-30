# MuseScore to develop a plugin
I checked all the procedure.
This documentation is based on the web page : https://musescore.org/fr/handbook/developers-handbook/compilation/compile-instructions-windows-visual-studio  

# Explanations on MuseScore installation to develop a plugin  
1. Download a MuseScore version on github MuseScore
2. Extract MuseScore to a local folder (named MuseScoreRoot after)
3. Extract dependencies.7z on MuseScoreRoot folder to access to lame (Mp3). (This will create a new dependencies subfolder within.)
   There are several additional dependencies:
   - LAME
   - libogg
   - libsndfile
   - libvorbis
   - libvorbisfile
   - Portaudio
   - WinSparkle
   - zlib  
   All of these are open-source projects. Although it is possible to download them individually and build them yourself to create the required libraries, it is much easier to use prebuilt libraries and include files.
4. ***Modify Cmake setting for Visual Studio 2022***
In MuseScore Root, you have a file CMakeSettings.json. Rename this in CMakeSettings.json.old and create the same file CMakeSettings.json.
In this file replace "Visual Studio 16 2019 Win64" by "Visual Studio 17 2022 Win64".
If you dont do that, Cmake finish with errors and impossible to build MuseScore.

NOTE: as of 1220175, 04Dec2020, LAME and PortAudio are no longer needed nor supported in the master (4.0) branch. They are still needed if you wish to build 3.6.2 or earlier versions.

# Install Visual Studio with good options (with VS 2022 for example)
These instructions are for building MuseScore with VS2022. Any edition of this version of Visual Studio should work, including the Community edition, which is full-featured and free to use for open-source projects.

Whether or not you already have Visual Studio installed, please read these instructions carefully, as you might need to install some additional components.

If you do not already have VS2022 installed, download Visual Studio Community https://visualstudio.microsoft.com/vs/community

## Use Visual Studio installer  
When you run the Visual Studio installer (either for the first time, or after installing, to change options), you will get eventually to the Workloads tab. Make sure the Desktop development with C++ option is selected.  

![image](https://user-images.githubusercontent.com/101040777/209845012-a41ef8d8-84f9-42b3-afbb-ad6bd26c753b.png)

Go to "Develoment Desktop in C++" and open options. Make sure the following options are all selected:

VS2022:
- Code tools:
  - Git for Windows
  - Help Viewer
- Compilers, build tools, and runtimes:
  - Tools C++ CMake tools for Windows
  - MSVC v143 - VS 2022 C++ x64/x86 build tools (or the latest version available)
  - Windows SDK, depending on your OS:
    - ***Windows 10 SDK (10.0.20348.0 or later).*** This version contains necessary WinRT libs. If the above SDK does not show up in the VS Installer, you can find the appropriate SDK at the Microsoft SDK Archive https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/  
    - ***Windows 11 SDK (latest)***
 - Uncategorized:
    - GitHub Extension for Visual Studio // Option doesn't exit  
Note that as of 484f8dc, 09Oct2020, Qt 5.15 (and a C++17 capable toolchain, which with MSVC 2019 is a given) is required for the master branch.

Now, let it install (or update), grab a coffee (or a tea, a soda, a beer… whatever you prefer), and be patient.
## Use Visual Studio 2022
Once Visual Studio has been installed, start it and link it with your Microsoft account. (If you don't have one, create one).  
Go to Tools > Extensions > Manage Extensions.  
On the left side of the dialog, select Online, then enter “qt” in the search box at the top right, and select and ***install Qt Visual Studio Tools***. Although this is not strictly needed, it can be handy later.
![image](https://user-images.githubusercontent.com/101040777/209846694-7e2e4f5a-2311-4676-bac1-6c18c8c5c8c3.png)  
While you are here, you can go to Tools > Options… and review and edit the editor options to your liking. (This can be done per-language, and there are tons of settings!)

## Visual Studio 2022 settings
It's not needed but I advise you to set Visual Studio with verbose options to see where are errors if there is one (or two, or...) for the first try to build MuseScore.
When you open Visual Studio 2022, options are :
- Go to Tools >> Options >> Cmake >> General : activer "activer la sortie Cmake détaillée"; "activer la journalisation des diagnostics internes"; niveau de verbosivité "commentaires"; journaliser dans un fichier (to have a log file if there is an error. And There is often errors the first time...)
- Go to Tools >> Options >> Qt >> General : check "Show debug information" = "Enable"; "verbosity of background build log" = "Diagnostic"

# CMake

CMake is used for generating the Visual Studio solution and project files needed for building MuseScore.

If you're building a ***standard build***, Visual Studio will automatically use its own internal copy of CMake, so you don't need to download it separately.
If you're building an ***advanced build***, you will need to download and install CMake.

***(For information on the difference between standard and advanced builds, see building.)***

- For advanced building : Download and install CMake https://cmake.org/download/ .
  - Add the CMake bin subfolder to the Path environment variable; typically, this will be %ProgramFiles%\CMake\bin.

# Qt

You will need the Qt libraries, minimum version 5.15.2, to be able to build MuseScore. For the 3.x branch Qt 5.9 is sufficient (but the others work too, but as of 583c71c, 01Dec2020, the builds don't run when build with Qt 5.15, they crash on start or when opening a pre-3.6 score... no longer the case fortunately since at least 3.6RC), for the master branch as of 484f8dc (09Oct2020) you'd need 5.15. Go for 5.15.2, the latest and last publicly available Qt 5 release (MuseScore isn't yet ready for Qt 6, or the other way round).

    Go to Download Qt: Get Qt Online Installer and follow the steps to download and launch the online installer.
    If you're not in the US or Europe, you'll probably want to launch the installer with a specific mirror, as per https://wiki.qt.io/Online_Installer_4.x#Selecting_a_mirror_for_opensour…
    Install Qt in the default location.
    Ensure you select custom install
    Choose a Qt version (5.15.2, but see above) and install the following components for that version:
        MSVC 2019 64-bit (Qt 5.15)
        Qt WebEngine (not needed anymore for the master branch)
        Qt Network Authorization
        Optional, for 32-bit builds of MuseScore: MSVC 2017 32-bit (not available for Qt 5.9.9; instead, install MSVC 2015 32-bit, which will also work for VS2017 and VS2019, or MSVC 2015 32-bit for Qt 5.15)
        Optional, to make debugging easier: Qt Debug Information Files (not available for Qt 5.9.9)
    Add the path of the Qt bin subfolder (e.g., C:\Qt\5.15.2\msvc2019_64\bin) to the PATH environment variable.
    Tip: If you get CMake “can't find resource” failures later on, it's probably because the path of the Qt bin subfolder has not been correctly added to the PATH environment variable.
    Remove the MinGW C:\Qt\5.*\mingw*\bin folder from the PATH environment variable, if present.

# JACK - needed even if you have a recent release of build
https://github.com/jackaudio  
https://github.com/jackaudio/jackaudio.github.com/releases  
NOTE: as of 1220175, 04Dec2020, JACK is no longer needed nor supported in the master branch, however it is needed if you wish to build 3.6.2 or earlier.

Download the 64-bit Windows installer for the latest version of JACK.  
Install JACK in the default location.  

# 7-Zip
You will need a utility that handles .7z compressed files. 7-Zip is open-source, free, and quite powerful, but there are alternatives that will work as well.

# Building

Before you can build MuseScore, you need to download and install all of the prerequisites (above).

MuseScore can be built in three different configurations:
- Release: Runs fast with all performance optimizations enabled, but very difficult to debug.
- Debug: Very easy to debug, but runs very slow because all performance optimizations have been disabled.
- RelWithDebInfo: A compromise between Release and Debug. Runs faster than Debug but is more difficult to debug; conversely, easier to debug than Release but runs somewhat slower.

For each of these three configurations, MuseScore can be built for either 32-bit or 64-bit Windows.

***A standard build of MuseScore uses the RelWithDebInfo configuration for 64-bit Windows. To build this, follow the procedure for a standard build.***  
***To build MuseScore in other configurations, or for 32-bit Windows, follow the instructions for advanced builds.***

## Standard build (RelWithDebInfo configuration for 64-bit Windows)

***Reboot your system***
Open Visual Studio 2022.
- Go to continue without code
- Go to File > Open > Folder… and open the MuseScoreRoot folder.

Visual Studio will automatically begin to generate a CMake cache, which will include the Visual Studio solution and project files.

In Visual Studio, a solution is a collection of projects, grouped together, and sharing some basic characteristics. A project corresponds to a specific output being generated (such as an executable or a library). A project can exist by itself or within a solution, and a solution can contain one or more projects. CMake creates a single solution, with a different project for each logical component of MuseScore. The MuseScore solution contains over two dozen projects.

CMake cache generation will take a while. Watch the Output window and wait for the completion message to appear: ***"CMake generation finished"***. in french ***"Fin de la génération de CMake."***

If everything has worked as it should, Visual Studio will have created a Visual Studio solution file called mscore.sln inside the msvc.build_x64 subfolder of the MuseScoreRoot folder, along with a collection of Visual Studio project files (*.vcxproj).

Now you see the MuseScoreRoot and subfolders but you don't see a project. So:
- close MuseScoreRoot
- go to musescore.sln (in msvc.build_x64 subfolder) to start the project.
To do this, the recommended process for running/building is:
- Go to File > Close Folder to close the MuseScore checkout folder.
- Go to File > Open > Project/Solution…, then navigate to the msvc.build_x64 folder and open the mscore.sln Visual Studio solution file.

The Solution Explorer window should now look like this:  
![ExplorerSolution](https://github.com/bubu93200/MIT/blob/cd5a79be6a14470cc85bfd50a128a3287ea94ee3/MuseScoreRessources/ExplorerSolution.png)

Note the small red “minus sign” icons to the left of each project. Those icons mean that the project files are being excluded from the Git repository. Any directories or files with this icon are excluded and will not be included in any commits that you make.

In the Solution Explorer window, select the mscore project, then go to Build > Build mscore. (Alternatively, right-click the mscore project and choose Build from the popup menu.)

Building will take a while. Visual Studio will automatically build all of the other projects that mscore depends on. Watch the Output window and wait for the completion message to appear:
========== Build: 25 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========

In the Solution Explorer window, select the INSTALL project, then go to Build > Build INSTALL. (Alternatively, right-click the INSTALL project and choose Build from the popup menu.)

Watch the Output window and wait for the completion message to appear:
========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========

Note: Although building the INSTALL project is required, it need be done only once. Unless you change external resources (e.g. templates, workspaces, soundfonts, or translations) or change the build configuration, there is no need to build the INSTALL project again.


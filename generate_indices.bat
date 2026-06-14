@echo off
setlocal enabledelayedexpansion

set "RootFolder=%~1"
if "%RootFolder%"=="" set "RootFolder=%CD%"

set "ContentDir=%RootFolder%\content"
set "IndexDir=%RootFolder%\index"
set "MainOutputFile=%RootFolder%\index.html"

if not exist "%ContentDir%\" (
    echo Error: The "content" folder was not found inside "%RootFolder%".
    echo Please ensure this script is run from your root directory.
    exit /b 1
)

rem CRITICAL FIX: Clean and reset the index folder ONCE at the very beginning
if exist "%IndexDir%" rmdir /s /q "%IndexDir%"
mkdir "%IndexDir%"

rem ==========================================
rem STEP 1: Generate Top-Level Root index.html
rem ==========================================
(
    echo ^<!DOCTYPE html^>
    echo ^<html lang="en"^>
    echo ^<head^>
    echo     ^<meta charset="UTF-8"^>
    echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
    echo     ^<title^>Sagar Rajen Kapadia ^| Knowledge Hub^</title^>
    echo     ^<link rel="stylesheet" href="index.css"^>
    echo ^</head^>
    echo ^<body^>
    echo     ^<header^>
    echo         ^<div class="hero"^>
    echo             ^<h1^>Sagar Rajen Kapadia^</h1^>
    echo             ^<p class="tagline"^>Researcher • Strategic Analyst • Civilizational Observer^</p^>
    echo         ^</div^>
    echo     ^</header^>
    echo     ^<nav^>
    echo         ^<div class="nav-container"^>
    echo             ^<div class="nav-logo"^>SKX360^</div^>
    echo             ^<ul class="nav-links"^>
    echo                 ^<li^>^<a href="#"^>Home^</a^>^</li^>
    echo                 ^<li^>^<a href="#about"^>About^</a^>^</li^>
    echo                 ^<li^>^<a href="#documents"^>Document Index^</a^>^</li^>
    echo             ^</ul^>
    echo         ^</div^>
    echo     ^</nav^>
    echo     ^<main^>
    echo         ^<section id="documents" class="section"^>
    echo             ^<h2^>Document Index^</h2^>
    echo             ^<div class="index-grid"^>
) > "%MainOutputFile%"

rem Link root categories directly to index/ folder targets
for /d %%D in ("%ContentDir%\*") do (
    set "DirName=%%~nD"
    if /i not "!DirName!"=="doc" if /i not "!DirName!"=="docs" (
        set "CleanDirName=!DirName!"
        set "CleanDirName=!CleanDirName:_= !"
        call :TitleCase CleanDirName
        (
            echo                 ^<div class="index-card"^>
            echo                     ^<h3^>^<a href="index/!DirName!.html"^>!CleanDirName!^</a^>^</h3^>
            echo                     ^<p^>Repository for !CleanDirName! structural documentation and research.^</p^>
            echo                 ^</div^>
        ) >> "%MainOutputFile%"
    )
)

(
    echo             ^</div^>
    echo         ^</section^>
    echo     ^</main^>
    echo     ^<footer^>
    echo         ^<p^>© 2026 Sagar Rajen Kapadia • Cloud Nine Consulting • Surat, Gujarat, India^</p^>
    echo     ^</footer^>
    echo ^</body^>
    echo ^</html^>
) >> "%MainOutputFile%"


rem ==========================================
rem STEP 2: Generate Deep Sub-folder Indices
rem ==========================================
pushd "%ContentDir%"

for /d /r %%D in (*) do (
    set "TargetDir=%%~fD"
    
    rem Force relative tracking by analyzing the path relative to content folder context
    set "RelPath=%%~pnD"
    set "RelPath=!RelPath:*content=!"
    if "!RelPath:~0,1!"=="\" set "RelPath=!RelPath:~1!"
    if "!RelPath:~-1!"=="\" set "RelPath=!RelPath:~0,-1!"
    
    set "DirName=%%~nD"
    
    rem Skip word doc folders completely
    set "Skip=0"
    if /i "!DirName!"=="doc" set "Skip=1"
    if /i "!DirName!"=="docs" set "Skip=1"
    echo \!RelPath!\ | findstr /i "\\doc\\" >nul && set "Skip=1"
    echo \!RelPath!\ | findstr /i "\\docs\\" >nul && set "Skip=1"
    
    if "!Skip!"=="0" (
        set "HasPDFs=0"
        if exist "%%D\*.pdf" set "HasPDFs=1"
        
        set "HasSubdirs=0"
        for /d %%S in ("%%D\*") do (
            set "SubName=%%~nS"
            if /i not "!SubName!"=="doc" if /i not "!SubName!"=="docs" set "HasSubdirs=1"
        )
        
        rem Apply PDF folding rule (collapse 'pdf' folders into parent layout names)
        set "ActualHTMLPath=!RelPath!"
        if /i "!DirName!"=="pdf" (
            set "ActualHTMLPath=!RelPath:\pdf=!"
            for %%P in ("%%D\..") do set "DirName=%%~nP"
        )
        
        set "SubFolderOutputFile=%IndexDir%\!ActualHTMLPath!.html"
        
        rem Dynamically construct missing parent folder steps inside the index directory tree
        for %%I in ("!SubFolderOutputFile!") do set "ParentHTMLDir=%%~dpI"
        if not exist "!ParentHTMLDir!" mkdir "!ParentHTMLDir!"
        
        rem Calculate accurate relative depth stepbacks for styles (../../index.css)
        set "BackPath=../"
        set "VarPath=!ActualHTMLPath!"
        :LoopDepth
        for /f "tokens=1* delims=\" %%a in ("!VarPath!") do (
            if not "%%b"=="" (
                set "BackPath=!BackPath!../"
                set "VarPath=%%b"
                goto :LoopDepth
            )
        )
        set "CSSPath=!BackPath!index.css"
        set "HomePath=!BackPath!index.html"
        
        set "CleanSubDir=!DirName!"
        set "CleanSubDir=!CleanSubDir:_= !"
        call :TitleCase CleanSubDir
        
        rem -------------------------------------------------------------
        rem Case A: Leaf folder containing PDFs
        rem -------------------------------------------------------------
        if "!HasPDFs!"=="1" if not "!HasSubdirs!"=="1" (
            (
                echo ^<!DOCTYPE html^>
                echo ^<html lang="en"^>
                echo ^<head^>
                echo     ^<meta charset="UTF-8"^>
                echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
                echo     ^<title^>!CleanSubDir! ^| Sagar Rajen Kapadia^</title^>
                echo     ^<link rel="stylesheet" href="!CSSPath!"^>
                echo ^</head^>
                echo ^<body^>
                echo     ^<header^>
                echo         ^<div class="hero"^>
                echo             ^<h1^>!CleanSubDir!^</h1^>
                echo             ^<p class="tagline"^>Research Papers and Structural Analysis^</p^>
                echo         ^</div^>
                echo     ^</header^>
                echo     ^<nav^>
                echo         ^<div class="nav-container"^>
                echo             ^<div class="nav-logo"^>SKX360^</div^>
                echo             ^<ul class="nav-links"^>
                echo                 ^<li^>^<a href="!HomePath!"^>← Home^</a^>^</li^>
                echo             ^</ul^>
                echo         ^</div^>
                echo     ^</nav^>
                echo     ^<main^>
                echo         ^<section class="section"^>
                echo             ^<h2^>!CleanSubDir! Documentation^</h2^>
                echo             ^<div class="index-grid"^>
            ) > "!SubFolderOutputFile!"
            
            set "WebPDFPath=!RelPath:\=/!"
            for %%F in ("%%D\*.pdf") do (
                set "CleanFileName=%%~nF"
                set "CleanFileName=!CleanFileName:_= !"
                call :TitleCase CleanFileName
                (
                    echo                 ^<div class="index-card"^>
                    echo                     ^<h3^>^<a href="!BackPath!content/!WebPDFPath!/%%~nxF" target="_blank"^>!CleanFileName!^</a^>^</h3^>
                    echo                 ^</div^>
                ) >> "!SubFolderOutputFile!"
            )
            
            (
                echo             ^</div^>
                echo         ^</section^>
                echo     ^</main^>
                echo     ^<footer^>
                echo         ^<p^>© 2026 Sagar Rajen Kapadia • Cloud Nine Consulting • Surat, Gujarat, India^</p^>
                echo         ^<p class="footer-tagline"^>^<a href="!HomePath!" style="color: #ccc; text-decoration: none;"^>← Back to Home^</a^>^</p^>
                echo     ^</footer^>
                echo ^</body^>
                echo ^</html^>
            ) >> "!SubFolderOutputFile!"
            
        rem -------------------------------------------------------------
        rem Case B: Intermediary Node Sub-folders
        rem -------------------------------------------------------------
        ) else if "!HasSubdirs!"=="1" (
            (
                echo ^<!DOCTYPE html^>
                echo ^<html lang="en"^>
                echo ^<head^>
                echo     ^<meta charset="UTF-8"^>
                echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
                echo     ^<title^>!CleanSubDir! ^| Sagar Rajen Kapadia^</title^>
                echo     ^<link rel="stylesheet" href="!CSSPath!"^>
                echo ^</head^>
                echo ^<body^>
                echo     ^<header^>
                echo         ^<div class="hero"^>
                echo             ^<h1^>!CleanSubDir!^</h1^>
                echo             ^<p class="tagline"^>Sub-categories^</p^>
                echo         ^</div^>
                echo     ^</header^>
                echo     ^<nav^>
                echo         ^<div class="nav-container"^>
                echo             ^<div class="nav-logo"^>SKX360^</div^>
                echo             ^<ul class="nav-links"^>
                echo                 ^<li^>^<a href="!HomePath!"^>← Home^</a^>^</li^>
                echo             ^</ul^>
                echo         ^</div^>
                echo     ^</nav^>
                echo     ^<main^>
                echo         ^<section class="section"^>
                echo             ^<h2^>!CleanSubDir! Sub-indexes^</h2^>
                echo             ^<div class="index-grid"^>
            ) > "!SubFolderOutputFile!"
            
            for /d %%S in ("%%D\*") do (
                set "SubName=%%~nS"
                if /i not "!SubName!"=="doc" if /i not "!SubName!"=="docs" (
                    set "CleanCardName=!SubName!"
                    set "CleanCardName=!CleanCardName:_= !"
                    call :TitleCase CleanCardName
                    
                    set "ChildPath=!RelPath!\!SubName!"
                    set "WebCardLink=!ChildPath:\=/!"
                    set "WebCardLink=!WebCardLink:/pdf=!"
                    (
                        echo                 ^<div class="index-card"^>
                        echo                     ^<h3^>^<a href="!BackPath!index/!WebCardLink!.html"^>!CleanCardName!^</a^>^</h3^>
                        echo                     ^<p^>Explore !CleanCardName! documents and categories.^</p^>
                        echo                 ^</div^>
                    ) >> "!SubFolderOutputFile!"
                )
            )
            
            (
                echo             ^</div^>
                echo         ^</section^>
                echo     ^</main^>
                echo     ^<footer^>
                echo         ^<p^>© 2026 Sagar Rajen Kapadia • Cloud Nine Consulting • Surat, Gujarat, India^</p^>
                echo         ^<p class="footer-tagline"^>^<a href="!HomePath!" style="color: #ccc; text-decoration: none;"^>← Back to Home^</a^>^</p^>
                echo     ^</footer^>
                echo ^</body^>
                echo ^</html^>
            ) >> "!SubFolderOutputFile!"
        )
    )
)

popd
echo.
echo Process Complete! Pure progressive hierarchy generated inside the /index/ folder.
pause
exit /b

:TitleCase
set "str=!%1!"
set "result="
for %%w in (!str!) do (
    set "word=%%w"
    set "first=!word:~0,1!"
    set "rest=!word:~1!"
    set "result=!result! !first!!rest!"
)
set "result=!result:~1!"
set "%1=!result!"
goto :EOF
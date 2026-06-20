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

rem Reset and clear out the old index repository folder completely
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

rem Loop Level 1: Find direct subfolders of content/ (e.g., articles, financial_systems)
for /d %%C in ("%ContentDir%\*") do (
    set "CatName=%%~nC"
    if /i not "!CatName!"=="doc" if /i not "!CatName!"=="docs" (
        
        rem Loop Level 2: Find Subjects inside the Category (e.g., Quantum_Physics, global_macro)
        for /d %%S in ("%%C\*") do (
            set "SubjName=%%~nS"
            if /i not "!SubjName!"=="doc" if /i not "!SubjName!"=="docs" (
                
                set "CleanSubjName=!SubjName!"
                set "CleanSubjName=!CleanSubjName:_= !"
                call :TitleCase CleanSubjName
                
                (
                    echo                 ^<div class="index-card"^>
                    echo                     ^<h3^>^<a href="index/!CatName!/!SubjName!.html"^>!CleanSubjName!^</a^>^</h3^>
                    echo                     ^<p^>Repository for !CleanSubjName! documents and strategic analysis.^</p^>
                    echo                 ^</div^>
                ) >> "%MainOutputFile%"
            )
        )
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
rem STEP 2: Progressive Generation of Subject Index Files
rem ==========================================

rem Loop Level 1: Categories
for /d %%C in ("%ContentDir%\*") do (
    set "CatName=%%~nC"
    if /i not "!CatName!"=="doc" if /i not "!CatName!"=="docs" (
        
        rem Loop Level 2: Subjects
        for /d %%S in ("%%C\*") do (
            set "SubjName=%%~nS"
            if /i not "!SubjName!"=="doc" if /i not "!SubjName!"=="docs" (
                
                set "SubFolderOutputFile=%IndexDir%\!CatName!\!SubjName!.html"
                
                rem Build the dynamic targeted branch directory layout inside index/
                if not exist "%IndexDir%\!CatName!" mkdir "%IndexDir%\!CatName!"
                
                set "CleanTitle=!SubjName!"
                set "CleanTitle=!CleanTitle:_= !"
                call :TitleCase CleanTitle
                
                rem Level 2 files sit exactly at index/category/subject.html (Depth of 2 = ../../ stepbacks)
                set "CSSPath=../../index.css"
                set "HomePath=../../index.html"
                
                (
                    echo ^<!DOCTYPE html^>
                    echo ^<html lang="en"^>
                    echo ^<head^>
                    echo     ^<meta charset="UTF-8"^>
                    echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
                    echo     ^<title^>!CleanTitle! ^| Sagar Rajen Kapadia^</title^>
                    echo     ^<link rel="stylesheet" href="!CSSPath!"^>
                    echo ^</head^>
                    echo ^<body^>
                    echo     ^<header^>
                    echo         ^<div class="hero"^>
                    echo             ^<h1^>!CleanTitle!^</h1^>
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
                    echo             ^<h2^>!CleanTitle! Index^</h2^>
                ) > "!SubFolderOutputFile!"
                
                rem --- CHECK FOR DIRECT LOOSE PDFs (Level 2 Main) ---
                set "HasBasePDFs=0"
                if exist "%%S\*.pdf" set "HasBasePDFs=1"
                if exist "%%S\pdf\*.pdf" set "HasBasePDFs=1"
                
                if "!HasBasePDFs!"=="1" (
                    (
                        echo             ^<div class="index-grid"^>
                    ) >> "!SubFolderOutputFile!"
                    
                    for %%F in ("%%S\*.pdf") do (
                        set "CleanFileName=%%~nF"
                        set "CleanFileName=!CleanFileName:_= !"
                        call :TitleCase CleanFileName
                        (
                            echo                 ^<div class="index-card"^>
                            echo                     ^<h3^>^<a href="../../content/!CatName!/!SubjName!/%%~nxF" target="_blank"^>!CleanFileName!^</a^>^</h3^>
                            echo                 ^</div^>
                        ) >> "!SubFolderOutputFile!"
                    )
                    for %%F in ("%%S\pdf\*.pdf") do (
                        set "CleanFileName=%%~nF"
                        set "CleanFileName=!CleanFileName:_= !"
                        call :TitleCase CleanFileName
                        (
                            echo                 ^<div class="index-card"^>
                            echo                     ^<h3^>^<a href="../../content/!CatName!/!SubjName!/pdf/%%~nxF" target="_blank"^>!CleanFileName!^</a^>^</h3^>
                            echo                 ^</div^>
                        ) >> "!SubFolderOutputFile!"
                    )
                    (
                        echo             ^</div^>
                    ) >> "!SubFolderOutputFile!"
                )
                
                rem --- SCAN LEVEL 3 SUBFOLDERS (Syntax fixed using %%M instead of %%L3) ---
                for /d %%M in ("%%S\*") do (
                    set "L3Name=%%~nM"
                    if /i not "!L3Name!"=="doc" if /i not "!L3Name!"=="docs" if /i not "!L3Name!"=="pdf" (
                        
                        set "HasL3PDFs=0"
                        if exist "%%M\*.pdf" set "HasL3PDFs=1"
                        if exist "%%M\pdf\*.pdf" set "HasL3PDFs=1"
                        
                        if "!HasL3PDFs!"=="1" (
                            set "CleanHeading=!L3Name!"
                            set "CleanHeading=!CleanHeading:_= !"
                            call :TitleCase CleanHeading
                            
                            (
                                echo             ^<h3 class="section-subtitle" style="margin-top:40px; border-bottom:1px solid #ddd; padding-bottom:8px; color:#0a3d62;"^>!CleanHeading!^</h3^>
                                echo             ^<div class="index-grid"^>
                            ) >> "!SubFolderOutputFile!"
                            
                            for %%F in ("%%M\*.pdf") do (
                                set "CleanFileName=%%~nF"
                                set "CleanFileName=!CleanFileName:_= !"
                                call :TitleCase CleanFileName
                                (
                                    echo                 ^<div class="index-card"^>
                                    echo                     ^<h3^>^<a href="../../content/!CatName!/!SubjName!/!L3Name!/%%~nxF" target="_blank"^>!CleanFileName!^</a^>^</h3^>
                                    echo                 ^</div^>
                                ) >> "!SubFolderOutputFile!"
                            )
                            for %%F in ("%%M\pdf\*.pdf") do (
                                set "CleanFileName=%%~nF"
                                set "CleanFileName=!CleanFileName:_= !"
                                call :TitleCase CleanFileName
                                (
                                    echo                 ^<div class="index-card"^>
                                    echo                     ^<h3^>^<a href="../../content/!CatName!/!SubjName!/!L3Name!/pdf/%%~nxF" target="_blank"^>!CleanFileName!^</a^>^</h3^>
                                    echo                 ^</div^>
                                ) >> "!SubFolderOutputFile!"
                            )
                            (
                                echo             ^</div^>
                            ) >> "!SubFolderOutputFile!"
                        )
                    )
                )
                
                (
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
)

echo.
echo Process Complete! Consolidated Subject level HTML maps generated successfully.
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
@echo off
setlocal

:::  ________  _______   ________   _______   ___      ___ ________  ___       _______   ________   ________  _______      
::: |\   __  \|\  ___ \ |\   ___  \|\  ___ \ |\  \    /  /|\   __  \|\  \     |\  ___ \ |\   ___  \|\   ____\|\  ___ \     
::: \ \  \|\ /\ \   __/|\ \  \\ \  \ \   __/|\ \  \  /  / | \  \|\  \ \  \    \ \   __/|\ \  \\ \  \ \  \___|\ \   __/|    
:::  \ \   __  \ \  \_|/_\ \  \\ \  \ \  \_|/_\ \  \/  / / \ \  \\\  \ \  \    \ \  \_|/_\ \  \\ \  \ \  \    \ \  \_|/__  
:::   \ \  \|\  \ \  \_|\ \ \  \\ \  \ \  \_|\ \ \    / /   \ \  \\\  \ \  \____\ \  \_|\ \ \  \\ \  \ \  \____\ \  \_|\ \ 
:::    \ \_______\ \_______\ \__\\ \__\ \_______\ \__/ /     \ \_______\ \_______\ \_______\ \__\\ \__\ \_______\ \_______\
:::     \|_______|\|_______|\|__| \|__|\|_______|\|__|/       \|_______|\|_______|\|_______|\|__| \|__|\|_______|\|_______|
::: 
:::  _____ ______   _______   ________   ________  ___  ________  ___  ___     
::: |\   _ \  _   \|\  ___ \ |\   ____\ |\   ____\|\  \|\   __  \|\  \|\  \    
::: \ \  \\\__\ \  \ \   __/|\ \  \___|_\ \  \___|\ \  \ \  \|\  \ \  \\\  \   
:::  \ \  \\|__| \  \ \  \_|/_\ \_____  \\ \_____  \ \  \ \   __  \ \   __  \  
:::   \ \  \    \ \  \ \  \_|\ \|____|\  \\|____|\  \ \  \ \  \ \  \ \  \ \  \ 
:::    \ \__\    \ \__\ \_______\____\_\  \ ____\_\  \ \__\ \__\ \__\ \__\ \__\
:::     \|__|     \|__|\|_______|\_________\\_________\|__|\|__|\|__|\|__|\|__|
:::                             \|_________\|_________|

for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A

timeout /t 3

:: Unzip assets and delete archives.
echo Attempting initial install of virtual environment, FFMPEG, and pretrained AI models.
echo Ignore any error messages as this script will run each time after the intitial install.
gci -Recurse -Filter *.zip |ForEach-Object {Expand-Archive -Path $_.Fullname -DestinationPath $_.BaseName -Force}

pause

del ffmpeg.zip
del pretrained_weights.zip
del LivePortrait_env.zip

:: Attempt to activate the LivePortrait environment and capture any error messages in a file
echo Activating the LivePortrait environment...
call LivePortrait_env\Scripts\activate > nul 2>env_error.txt

:: Check the exit status of the previous command to see if the activation was successful
if %ERRORLEVEL% NEQ 0 (
    echo Activation failed. Displaying the error message:
    type env_error.txt
    echo Press any key to exit...
    pause >nul
    goto :eof
) else (
    echo Environment activated successfully.
)

:: Delete the error message file regardless of whether activation was successful
if exist env_error.txt del env_error.txt

:: Define the server's listening port
set SERVER_PORT=8890

:: Choose Human or Animal
:Menu1
echo Run inference for humans or animals?
echo ---------------------------------------------------------------
echo 1) Human
echo 2) Animal
set /P option=Enter your choice:
if %option% == 1 goto LaunchHuman
if %option% == 2 goto LaunchAnimal

:: Start the server in the background (Huaman)
:LaunchHuman
echo Starting the server...
start /B python app.py
:: Start the server in the background (Animal)
:LaunchAnimal
echo Starting the server...
start /B python app_animals.py

:: Wait for a moment to allow the server to start
echo Waiting for the server to start...
timeout /t 10 >nul

:: Infinite loop to keep checking the port status
:check_port
echo Checking if the server is listening on port %SERVER_PORT%...
for /f %%i in ('python ./src/utils/check_windows_port.py %SERVER_PORT%') do (
    if "%%i" == "LISTENING" (
        echo Server is up and running on http://127.0.0.1:%SERVER_PORT%
        :: Open the default browser to the server's URL
        start http://127.0.0.1:%SERVER_PORT%
        :: Keep the batch file running and display server output
        echo Server is running. Press Ctrl+C to stop.
        goto loop
    ) else (
        echo Server not ready, waiting 2 seconds...
        timeout /t 4 >nul
        goto check_port
    )
)

:loop
timeout /t 1 >nul
goto loop

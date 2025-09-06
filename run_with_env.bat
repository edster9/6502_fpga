@echo off
cd tools\oss-cad-suite
call environment.bat 2>nul || powershell.exe -ExecutionPolicy Bypass -File environment.ps1
cd ..\..
%*

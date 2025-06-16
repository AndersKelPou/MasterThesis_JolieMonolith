@echo off
setlocal

REM List of service names
set services=book clientapi dbhandler executionhandler hedgeservice marketdatagateway pricerengine riskcalculator

REM Loop through each service and run it with jolie
for %%s in (%services%) do (
    echo Starting %%s.ol...
    start cmd /k "jolie %%s.ol"
)

endlocal
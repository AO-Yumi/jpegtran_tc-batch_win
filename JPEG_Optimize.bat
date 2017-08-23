@echo off
REM JPEG transcode batch for jpegtran - version 1.1
REM   これはjpegtranによるJPEGトランスコードを
REM   　簡単に扱えるようにするためのパッチです。
REM   複数のフォルダ入力とファイル入力に対応しています。

setlocal enabledelayedexpansion

REM ---- USER SETTING -------------------------------------
REM "jpegtran.exe"の場所を絶対パスで指定（引用符有）
set BIN_DIST=""

REM "jpegtran.exe"に与えるオプションを設定（引用符無）
REM example:
REM   -copy [none/comments/all], -grayscale, -optimize
REM   -crop WxH+X+Y, -rotate [90|180|270]
REM   -revert(baseline) or -progressive [mozjpeg]
REM   (default baseline) or -progressive [IJG/libjpeg turbo]
set BIN_OPTION=

REM 出力パスを指定（引用符有）
set OUT_DIR=""

REM テストモード（1=有効、0=無効）
set TEST_SW=0
REM テストモード有効時の追加文字列（引用符無）
set TEST_NAME=mozjpeg

REM --- BATCH SETTING -------------------------------------
set OUT_EXT=.jpg
set FLAG=FALSE
set IFILE=0
set OPFILE=0
set OLFILE=0

if %TEST_SW% == 1 (
  set TEST_NAME=" [%TEST_NAME% %BIN_OPTION%]"
  echo %TEST_NAME%
) else (
  set TEST_NAME=""
)

if not exist %BIN_DIST% goto EX_CHECK_ERROR

echo. 
mkdir %OUT_DIR% 2> nul
for %%B in (%OUT_DIR%) do (
  echo OUTPUT-DIR "%%~fB"
  set OUT_DIR="%%~fB\"
)
if not exist %OUT_DIR% (
 goto OD_CHECK_ERROR
)

goto MAINSTART

:EX_CHECK_ERROR
echo Detect error.
echo   Illegal executable file path.
goto FINAL

:OD_CHECK_ERROR
echo Detect error.
echo   Illegal output directory.
goto FINAL

:QA_CHECK_ERROR
echo Detect error.
echo    Illegal quality setting.
goto FINAL

REM --- Main ----------------------------------------------
:MAINSTART
if not exist "%~1" goto AFTERWORKING

if exist "%~1\" (
  call :GETCNUM "%~dp1"
  set NUM_OPLACE2= !GETCNUM_RET!
  for /r "%~1" %%A in (*.jpg) do (
    echo In^|"%%~fA"
    set /a IFILE+=1
    call :RUNCUT "%%~dpnA" !NUM_OPLACE2!
    call :CONNECT_PATH %OUT_DIR% !WORKCUT!
    call :FIND_PATH !WORKCONNECT!
    mkdir !WORKFINDP! 2> nul
    set OUT_FILE=!WORKCONNECT!
    set /a OPFILE+=1
    call :CONNECT_PATH !OUT_FILE! %TEST_NAME%
    call :CONNECT_PATH !WORKCONNECT! "%OUT_EXT%"
    call :DECIDENAME !WORKCONNECT!
    %BIN_DIST% %BIN_OPTION% -outfile !DN_FILENAME! "%%~fA"
    call :CHECKFILE !DN_FILENAME!
    call :OUTWORK !ERRORLEVEL!
  )
  goto NEXT
)

set FLAG=FALSE
if /i "%~x1" == ".JPG" set FLAG=TRUE
if %FLAG%==FALSE goto NEXT

echo In^|"%~f1"
set /a IFILE+=1
set /a OPFILE+=1
call :CONNECT_PATH %OUT_DIR% "%~n1"
call :CONNECT_PATH %WORKCONNECT% %TEST_NAME%
call :CONNECT_PATH %WORKCONNECT% "%OUT_EXT%"
call :DECIDENAME %WORKCONNECT%
%BIN_DIST% %BIN_OPTION% -outfile %DN_FILENAME% "%~f1"
call :CHECKFILE %DN_FILENAME%
call :OUTWORK %ERRORLEVEL%


:NEXT
SHIFT
GOTO MAINSTART

:OUTWORK
if %1 GEQ 0 (
  set /a OLFILE+=1
  echo   ^|Out %DN_FILENAME%
) else (
  echo   ^|Err %DN_FILENAME%
)
exit /b

REM --- COMMON SUB ROUTINE ---------------------------------------

REM ---------------
REM 重複するファイルがあった場合は自動的にファイル名に番号を追加する。
REM 引数はフルパスのファイル名。
REM これはファイルの上書きを防止する。
:DECIDENAME
set DN_NUM=0
:DECIDENAME_LOOP
if %DN_NUM% == 0 (
  set DN_FILENAME="%~f1"
) else (
  set DN_FILENAME="%~dpn1 (%DN_NUM%)%~x1"
)
call :CHECKFILE %DN_FILENAME%
if %ERRORLEVEL% GEQ 0 (
  set /a DN_NUM+=1
  goto :DECIDENAME_LOOP
)
exit /b

REM ---------------
REM ファイルの存在とファイルサイズをチェックする。
REM 戻り値 -1      ファイルが存在しない
REM         0以上　ファイルが存在（ファイルサイズを返す）
:CHECKFILE
if exist "%~f1\" exit /b -1
if not exist "%~f1" exit /b -1
exit /b %~z1

REM ---------------
REM 前方から"%2"分の文字を削る。
REM 出力文字列は必ず引用句で括られる。
:RUNCUT
set WORKCUT="%~f1"
set /a CUTNUM=%2+1
set WORKCUT="!WORKCUT:~%CUTNUM%!
exit /b

REM ---------------
REM 入力された文字列を絶対パスとみなして拡張子以外を取り出す。
REM 全体は引用句で括られる。
:FIND_FILEPATH
set WORKFINDF="%~dpn1"
exit /b

REM ---------------
REM 入力された文字列を絶対パスとみなしてドライブ名とパス情報を取り出す。
REM 全体は引用句で括られる。
:FIND_PATH
set WORKFINDP="%~dp1"
exit /b

REM ---------------
REM %1と%2を連結する。
REM 全体は引用句で括られる。
:CONNECT_PATH
set WORKCONNECT="%~1%~2"
exit /b

REM ---------------
REM 渡された文字列の長さをGETCNUM_RETに入れる。
REM 呼び出し元の引数は引用句""で必ず囲むこと。
REM 環境変数GETCNUM_RETは他で使用しないこと。
:GETCNUM
set GETCNUM_TEMP="%~1"
set GETCNUM_RET=0
:GETCNUM_LOOP
if %GETCNUM_TEMP% == "" exit /b
REM 下の行は意図的にこうしているので注意
set GETCNUM_TEMP="%GETCNUM_TEMP:~2%
set /a GETCNUM_RET=GETCNUM_RET+1
goto GETCNUM_LOOP

REM --- FINISHED WORKING -------------------------------------
:AFTERWORKING
  echo.
if not %OPFILE% == %OLFILE% (
  echo Detect error.
  echo  "Output file(s): %OLFILE%(%OPFILE%)"
) else (
  if %IFILE% == 0 (
    echo Input file not found.
  ) else (
    echo "Converted number of file(s): in[%IFILE%] out[%OLFILE%]" 
    echo Complete.
  )
)
:FINAL
echo -- Hit any key --
pause > nul

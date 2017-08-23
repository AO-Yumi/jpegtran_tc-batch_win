@echo off
REM JPEG transcode batch for jpegtran - version 1.1
REM   �����jpegtran�ɂ��JPEG�g�����X�R�[�h��
REM   �@�ȒP�Ɉ�����悤�ɂ��邽�߂̃p�b�`�ł��B
REM   �����̃t�H���_���͂ƃt�@�C�����͂ɑΉ����Ă��܂��B

setlocal enabledelayedexpansion

REM ---- USER SETTING -------------------------------------
REM "jpegtran.exe"�̏ꏊ���΃p�X�Ŏw��i���p���L�j
set BIN_DIST=""

REM "jpegtran.exe"�ɗ^����I�v�V������ݒ�i���p�����j
REM example:
REM   -copy [none/comments/all], -grayscale, -optimize
REM   -crop WxH+X+Y, -rotate [90|180|270]
REM   -revert(baseline) or -progressive [mozjpeg]
REM   (default baseline) or -progressive [IJG/libjpeg turbo]
set BIN_OPTION=

REM �o�̓p�X���w��i���p���L�j
set OUT_DIR=""

REM �e�X�g���[�h�i1=�L���A0=�����j
set TEST_SW=0
REM �e�X�g���[�h�L�����̒ǉ�������i���p�����j
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
REM �d������t�@�C�����������ꍇ�͎����I�Ƀt�@�C�����ɔԍ���ǉ�����B
REM �����̓t���p�X�̃t�@�C�����B
REM ����̓t�@�C���̏㏑����h�~����B
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
REM �t�@�C���̑��݂ƃt�@�C���T�C�Y���`�F�b�N����B
REM �߂�l -1      �t�@�C�������݂��Ȃ�
REM         0�ȏ�@�t�@�C�������݁i�t�@�C���T�C�Y��Ԃ��j
:CHECKFILE
if exist "%~f1\" exit /b -1
if not exist "%~f1" exit /b -1
exit /b %~z1

REM ---------------
REM �O������"%2"���̕��������B
REM �o�͕�����͕K�����p��Ŋ�����B
:RUNCUT
set WORKCUT="%~f1"
set /a CUTNUM=%2+1
set WORKCUT="!WORKCUT:~%CUTNUM%!
exit /b

REM ---------------
REM ���͂��ꂽ��������΃p�X�Ƃ݂Ȃ��Ċg���q�ȊO�����o���B
REM �S�͈̂��p��Ŋ�����B
:FIND_FILEPATH
set WORKFINDF="%~dpn1"
exit /b

REM ---------------
REM ���͂��ꂽ��������΃p�X�Ƃ݂Ȃ��ăh���C�u���ƃp�X�������o���B
REM �S�͈̂��p��Ŋ�����B
:FIND_PATH
set WORKFINDP="%~dp1"
exit /b

REM ---------------
REM %1��%2��A������B
REM �S�͈̂��p��Ŋ�����B
:CONNECT_PATH
set WORKCONNECT="%~1%~2"
exit /b

REM ---------------
REM �n���ꂽ������̒�����GETCNUM_RET�ɓ����B
REM �Ăяo�����̈����͈��p��""�ŕK���͂ނ��ƁB
REM ���ϐ�GETCNUM_RET�͑��Ŏg�p���Ȃ����ƁB
:GETCNUM
set GETCNUM_TEMP="%~1"
set GETCNUM_RET=0
:GETCNUM_LOOP
if %GETCNUM_TEMP% == "" exit /b
REM ���̍s�͈Ӑ}�I�ɂ������Ă���̂Œ���
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

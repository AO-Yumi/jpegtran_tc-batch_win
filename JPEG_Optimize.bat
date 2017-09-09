@echo off
REM JPEG transcode batch for jpegtran - version 1.2
REM   �����jpegtran�ɂ��JPEG�g�����X�R�[�h��
REM   �@�ȒP�Ɉ�����悤�ɂ��邽�߂̃p�b�`�ł��B
REM   �����̃t�H���_���͂ƃt�@�C�����͂ɑΉ����Ă��܂��B

setlocal enabledelayedexpansion

REM ---- USER SETTING -------------------------------------
REM "jpegtran.exe"�̏ꏊ���w��i���p���t���𐄏��j
set BIN_DIST="jpegtran.exe"

REM "jpegtran.exe"�ɗ^����I�v�V������ݒ�i���p�����j
REM example:
REM   -copy [none/comments/all], -grayscale, -optimize
REM   -crop WxH+X+Y, -rotate [90|180|270]
REM   -revert(baseline) or -progressive [mozjpeg]
REM   (default baseline) or -progressive [IJG/libjpeg turbo]
set BIN_OPTION=-optimize

REM �o�̓p�X���w��i���p���t���𐄏��j
set OUT_DIR=""

REM �e�X�g���[�h�i1=�L���A0=�����j
set TEST_SW=0
REM �e�X�g���[�h�L�����̒ǉ�������i���p�����j
set TEST_NAME=mozjpeg

REM --- INTERNAL SETTING ----------------------------------
set OUT_EXT=.jpg
set IN_EXT=.jpg .jpeg
set OUTWORK_MODE=1
set MIN_OUTSIZE=10

set IFILE=0
set OPFILE=0
set OLFILE=0

set IN_DIR=%IN_EXT:.=*.%

if %TEST_SW% == 1 (
  set TEST_NAME=" [%TEST_NAME% %BIN_OPTION%]"
  echo %TEST_NAME%
) else (
  set TEST_NAME=""
)

call :SET_QUOTE_FP %OUT_DIR%
set OUT_DIR=%RET@SET_QUOTE_FP%
mkdir %OUT_DIR% 2> nul
if not exist %OUT_DIR% (
 goto OD_CHECK_ERROR
)
echo Output DIR %OUT_DIR%
call :CONNECT_PATH %OUT_DIR% "\"
set OUT_DIR=%RET@CONNECT_PATH%

%~d0
cd "%~p0"
call :SET_QUOTE_FP %BIN_DIST%
set BIN_DIST=%RET@SET_QUOTE_FP%
if not exist %BIN_DIST% goto EX_CHECK_ERROR
echo Available EXE %BIN_DIST%

echo. 
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
  call :VARI_LENGTH "%~dp1"
  set NUM_OPLACE2= !ERRORLEVEL!
  for /r "%~1" %%A in (%IN_DIR%) do (
    echo In^|"%%~fA"
    set /a IFILE+=1
    call :CUTCHAR_F "%%~dpnA" !NUM_OPLACE2!
    call :CONNECT_PATH %OUT_DIR% !RET@CUTCHAR_F!
    call :SET_PATH !RET@CONNECT_PATH!
    mkdir !RET@SET_PATH! 2> nul
    set OUT_FILE=!RET@CONNECT_PATH!
    set /a OPFILE+=1
    call :CONNECT_PATH !OUT_FILE! %TEST_NAME%
    call :CONNECT_PATH !RET@CONNECT_PATH! "%OUT_EXT%"
    call :DECIDENAME !RET@CONNECT_PATH!
    set DUP_FLAG=!ERRORLEVEL!
    call :EXE_RUN "%BIN_OPTION%" "%%~fA" !RET@DECIDENAME!
    call :OUTWORK !ERRORLEVEL! !RET@DECIDENAME! !DUP_FLAG!
  )
  goto NEXT
)

set CHECKEXT=FALSE
for %%A in (%IN_EXT%) do (
  if /i "%~x1" == "%%A" set CHECKEXT=TRUE
)
if %CHECKEXT%==FALSE goto NEXT

echo In^|"%~f1"
set /a IFILE+=1
set /a OPFILE+=1
call :CONNECT_PATH %OUT_DIR% "%~n1"
call :CONNECT_PATH %RET@CONNECT_PATH% %TEST_NAME%
call :CONNECT_PATH %RET@CONNECT_PATH% "%OUT_EXT%"
call :DECIDENAME %RET@CONNECT_PATH%
set DUP_FLAG=%ERRORLEVEL%
call :EXE_RUN "%BIN_OPTION%" "%~f1" %RET@DECIDENAME%
call :OUTWORK %ERRORLEVEL% %RET@DECIDENAME% %DUP_FLAG%

:NEXT
shift
goto MAINSTART

:EXE_RUN
REM 1=OPTION, 2=INPUT FILE, 3=OUTPUT FILE
REM OPTION�ɂ��Ă͈��p��Ŋ����ēn�����ƁB
REM �߂�l�͎��s�t�@�C���̖߂�l�����̂܂ܓn���B
%BIN_DIST% %~1 -outfile %3 %2

exit /b %ERRORLEVEL%

:OUTWORK
if %OUTWORK_MODE% == 1 (
  if %1 == 0 (
    set OUTWORK_FLAG=SUCCESS
  ) else set OUTWORK_FLAG=FAILURE
) else (
  call :CHECKFILE %2
  if !ERRORLEVEL! GEQ %MIN_OUTSIZE% (
    set OUTWORK_FLAG=SUCCESS
  ) else set OUTWORK_FLAG=FAILURE
)
if %OUTWORK_FLAG% == SUCCESS (
  set /a OLFILE+=1
  echo   ^|Out %2
  if %3 neq 0 echo     [Warning] Renamed filename.
) else if %OUTWORK_FLAG% == FAILURE (
  echo   ^|Err %2
) else echo   ^|?   %2
exit /b

REM --- COMMON SUB ROUTINE ---------------------------------------

REM ---------------
REM �d������t�@�C�����������ꍇ�͎����I�Ƀt�@�C�����ɔԍ���ǉ�����B
REM �����̓t���p�X�̃t�@�C�����B
REM ����̓t�@�C���̏㏑����h�~����B
:DECIDENAME
set TEMP_DECIDENAME=0
:DECIDENAME_LOOP
if %TEMP_DECIDENAME% == 0 (
  set RET@DECIDENAME="%~f1"
) else (
  set RET@DECIDENAME="%~dpn1 (%TEMP_DECIDENAME%)%~x1"
)
call :CHECKFILE %RET@DECIDENAME%
if %ERRORLEVEL% GEQ 0 (
  set /a TEMP_DECIDENAME+=1
  goto DECIDENAME_LOOP
)
exit /b %TEMP_DECIDENAME%

REM ---------------
REM �t�@�C���̑��݂ƃt�@�C���T�C�Y���`�F�b�N����B
REM �߂�l -1      �t�@�C�������݂��Ȃ�
REM         0�ȏ�@�t�@�C�������݁i�t�@�C���T�C�Y��Exit�R�[�h�ŕԂ��j
:CHECKFILE
if exist "%~f1\" exit /b -1
if not exist "%~f1" exit /b -1
exit /b %~z1

REM ---------------
REM �O������"%2"���̕��������B
REM �o�͕�����͕K�����p��(")�Ŋ�����B
:CUTCHAR_F
set RET@CUTCHAR_F="%~f1"
set /a TEMP_CUTCHAR_F=%2+1
set RET@CUTCHAR_F="!RET@CUTCHAR_F:~%TEMP_CUTCHAR_F%!
exit /b

REM ---------------
REM ���͂��ꂽ������ɑ΂��Ĉ��p��(")��ݒ肷��B
:SET_QUOTE
set RET@SET_QUOTE="%~1"
exit /b

REM ---------------
REM ���͂��ꂽ��������t�@�C���p�X�ƌ��Ȃ��A
REM ���S�C���p�X���ɓW�J���Ĉ��p��(")��ݒ肷��B
:SET_QUOTE_FP
set RET@SET_QUOTE_FP="%~f1"
exit /b

REM ---------------
REM ���͂��ꂽ������ɑ΂��Ĉ��p��(")���폜����B
:SET_QUOTE
set RET@SET_QUOTE=%~1
exit /b

REM ---------------
REM ���͂��ꂽ��������΃p�X�Ƃ݂Ȃ��Ċg���q�ȊO�����o���B
REM �S�͈̂��p��(")�Ŋ�����B
:SET_FILEWEXT
set RET@SET_FILEWEXT="%~dpn1"
exit /b

REM ---------------
REM ���͂��ꂽ��������΃p�X�Ƃ݂Ȃ��ăh���C�u���ƃp�X�������o���B
REM �S�͈̂��p��(")�Ŋ�����B
:SET_PATH
set RET@SET_PATH="%~dp1"
exit /b

REM ---------------
REM %1��%2��A������B
REM �S�͈̂��p��(")�Ŋ�����B
:CONNECT_PATH
set RET@CONNECT_PATH="%~1%~2"
exit /b

REM ---------------
REM �n���ꂽ������̒�����Exit�R�[�h�ŕԂ��B
REM �S�̂�������p��(")�͏�ɑ��݂�����̂Ƃ��ĕ��������v�Z����B
:VARI_LENGTH
set TEMP_VARI_LENGTH="%~1"
set TEMP_VARI_LENGTH_RET=0
:VARI_LENGTH_LOOP
if %TEMP_VARI_LENGTH% == "" exit /b %TEMP_VARI_LENGTH_RET%
REM ���̍s�͈Ӑ}�I�ɂ������Ă���̂Œ���
set TEMP_VARI_LENGTH="%TEMP_VARI_LENGTH:~2%
set /a TEMP_VARI_LENGTH_RET=TEMP_VARI_LENGTH_RET+1
goto VARI_LENGTH_LOOP

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

# Arduino Uploader

Arduino Uploader is a command-line tool that allows you to compile your Arduino source code, upload it to your Arduino board, and read the results.

## Dependencies

Before using Arduino Uploader, you need to make sure you have the following dependencies installed:

- `arduino-mk`
- `screen`
- `yad`

## Usage

To use Arduino Uploader, simply run the following command:

```
./arduino-uploader.sh [OPTIONS]
```

### Options

- `-h`: Show the help message.
- `-v`: Show the version number.
- `-s`: Show the serial monitor after uploading the program.
- `-c`: Show information about the compilation process.
- `-b BOARD_TYPE`: Set the board type. The available board types are listed below.
- `-l`: List the available board types.
- `-p WORK_DIR`: Set the working directory.
- `-i`: Show an interface to set the options.

### Available Board Types

- `atmega168`
- `atmega328`
- `atmega8`
- `bt328`
- `bt`
- `diecimila`
- `esplora`
- `ethernet`
- `fio`
- `leonardo`
- `lilypad328`
- `lilypad`
- `LilyPadUSB`
- `mega2560`
- `mega`
- `micro`
- `mini328`
- `mini`
- `nano328`
- `nano`
- `pro328`
- `pro5v328`
- `pro5v`
- `pro`
- `robotControl`
- `robotMotor`
- `uno`

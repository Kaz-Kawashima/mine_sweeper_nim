import termios, posix

var originalTermios: Termios

proc enableRawMode*() =
  discard tcgetattr(STDIN_FILENO, addr originalTermios)
  var raw = originalTermios
  raw.c_lflag = raw.c_lflag and not Cflag(ECHO or ICANON)
  discard tcsetattr(STDIN_FILENO, TCSAFLUSH, addr raw)

proc disableRawMode*() =
  discard tcsetattr(STDIN_FILENO, TCSAFLUSH, addr originalTermios)

proc getch(): char =
  var c: char
  discard read(STDIN_FILENO, addr c, 1)
  result = c

type
    GameInput* = enum
        Open, Flag, Up, Down, Left, Right, Quit

proc getKey*(): GameInput =
    while true:
        var input = getch()
        case input:
        of 'o', 'O':
            return Open
        of 'f', 'F':
            return Flag
        of 'q', 'Q':
            # echo "Quit"
            return Quit
        of '\x1b':
            input = getch()
            if input == '[':
                input = getch()
                case input:
                of 'A':
                    return Up
                of 'B':
                    return Down
                of 'C':
                    return Right
                of 'D':
                    return Left
                else:
                    discard
        else:
            # echo "input again"
            discard

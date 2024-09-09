{.emit: """
#include <conio.h>
""".}

proc getch(): cint {.importc, header: "<conio.h>".}

type
    GameInput* = enum
        Open,Flag,Up,Down,Left,Right,Quit

proc getKey*(): GameInput =
    while true:
        var input = getch()
        var ch = char(input)
        if input == 0x00 or input == 0xe0:
            input = getch()
            ch = char(input)
        case input:
        of cint('o'), cint('O'):
            return Open
        of cint('f'), cint('F'):
            return Flag
        of cint('q'), cint('Q'):
            # echo "Quit"
            return Quit
        of 0x4b:
            # echo "Left"
            return Left
        of 0x4d:
            # echo "Right"
            return Right
        of 0x48:
            # echo "Up"
            return Up
        of 0x50:
            # echo "Down"
            return Down
        else:
            # echo "input again"
            discard
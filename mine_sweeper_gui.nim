import nigui
import nigui/msgbox
import std/sugar
import std/enumerate
import std/strformat
import system
import mine_sweeper
import panel

# define game field
let num_col = 9
let num_row = 9
var gb = new GameBoard
gb.init(num_col, num_row, 10)


let button_size = 40
let margin_size = 5
let tile_size = button_size + margin_size * 2

app.init()

var window = newWindow("mine sweeper-- (F:0)")
window.width = (tile_size + 3) * num_col
window.height = (tile_size + 3) * num_row + 30

var container = newContainer()
window.add(container)

# set GUI
var button_mat: seq[seq[Button]]
for row in 0 ..< num_row:
    var button_row: seq[Button]
    for col in 0 ..< num_col:
        # Add a Button control:
        let label = " "
        var button = newButton(label)
        button_row.add(button)
        container.add(button)
        button.x = col * tile_size + margin_size
        button.y = row * tile_size + margin_size
        button.width = button_size
        button.height = button_size
    button_mat.add(button_row)

# reflesh game board GUI
proc reflesh(button_mat: seq[seq[Button]], gb: GameBoard) =
    for y, button_row in enumerate(1, button_mat):
        for x, button in enumerate(1, button_row):
            let Panel = gb.field[y][x]
            if Panel.isOpen:
                button.text = Panel.toString
                button.enabled = false
            elif Panel.isFlagged:
                button.text = "F"
                button.enabled = true
            else:
                button.text = " "
                button.enabled = true

# click action and game logic
proc open(gb: GameBoard, row, col: int, button_mat: seq[seq[Button]]) =
    let x = col + 1
    let y = row + 1
    if gb.getStatus() == Uninitialized:
        gb.setBombAll(y, x)
    let ret = gb.open(y, x)
    discard gb.getStatus()
    if ret:
        gb.cascadeOpen
        reflesh(button_mat, gb)
        let num_flag = gb.countFlags
        window.title = (fmt"mine sweeper-- (F:{num_flag})")
        if gb.isFinished:
            let res = window.msgBox("You Win! Click new game!")
            gb.init(num_col, num_row, 10)
            reflesh(button_mat, gb)
    else:
        gb.bombOpen
        reflesh(button_mat, gb)
        let res = window.msgBox("Game Over")
        quit(0)

proc flag(gb: GameBoard, row, col: int, button_mat: seq[seq[Button]]) =
    let x = col + 1
    let y = row + 1
    gb.flag(y, x)
    reflesh(button_mat, gb)
    let num_flag = gb.countFlags
    window.title = (fmt"mine sweeper-- (F:{num_flag})")


# set click event
for row in 0 ..< num_row:
    capture row:
        for col in 0 ..< num_col:
            capture col:
                var button = button_mat[row][col]
                capture button:
                    button.onMouseButtonDown = proc (event: MouseEvent) =
                        if event.button == MouseButtonLeft:
                            gb.open(row, col, button_mat)
                        elif event.button == MouseButtonRight:
                            gb.flag(row, col, button_mat)

window.show()
app.run()

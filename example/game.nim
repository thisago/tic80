# Default TIC-80 example game ported to nim
import tic80

const header = ticHeader(
  title = "game title",
  author = "game developer",
  desc = "short description"
)
{.emit: header.}

var
  t = 0
  x = 96
  y = 24

TIC:
  if btn BtnUp: y = y - 1
  if btn BtnDown: y = y + 1
  if btn BtnLeft: x = x - 1
  if btn BtnRight: x = x + 1

  cls(13)
  spr(1 + t mod 60 div 30 * 2, x, y, 14, 3, 0, 0, 2, 2)
  print("HELLO WORLD!", 84, 84)
  textri(64, 0, 0, 64, 64, 64, 32, 0, 0, 32, 32, 32, true, @[Color 14])
  t = t + 1

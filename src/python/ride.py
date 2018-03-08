from sleigh import Sleigh
import sys
import time
import curses
import curses.textpad


riders = []
RIDER_HEIGHT = 4  # name, distance, speed, accelerate
num_formatter_big = '{:4.3f}'
num_formatter_small = '{:1.4f}'


def redraw_riders(riders_window, empty_cell_size, name_formatter):
    riders_window.attron(curses.color_pair(1))
    vert_pos = 1 + empty_cell_size
    for rider in riders:
        riders_window.addstr(vert_pos, 0, name_formatter.format(rider._rider))
        riders_window.addstr(vert_pos + 1, 1, "d = " + num_formatter_big.format(rider._distance))
        riders_window.addstr(vert_pos + 2, 1, "v = " + num_formatter_small.format(rider._speed))
        riders_window.addstr(vert_pos + 3, 1, "a = " + num_formatter_small.format(rider._acceleration))
        vert_pos = vert_pos + RIDER_HEIGHT + empty_cell_size
    riders_window.attroff(curses.color_pair(1))


def draw_mileposts(window, max_pos, max_dist):
    width = window.getmaxyx()[1] - 2

    MILEPOSTS_DIST = 25

    left_side = max_dist - max_pos
    left_pos = abs(int(left_side) % MILEPOSTS_DIST - MILEPOSTS_DIST)
    while left_pos < width:
        window.addstr(3, left_pos, '\u2552\u2555')
        window.addstr(4, left_pos, '\u255E\u2561')
        left_pos = left_pos + MILEPOSTS_DIST + 2


def redraw_sleigh(sleigh_window, empty_cell_size):
    width = sleigh_window.getmaxyx()[1]
    distances = [rider._distance for rider in riders]
    max_dist = max(distances)

    vert_pos = empty_cell_size + 1
    diff_limit = width/2 + 14
    if max_dist < diff_limit:
        pass
    else:
        distances = [distance - (max_dist - diff_limit) for distance in distances]

    draw_mileposts(sleigh_window, max([dist for dist in distances if dist >= 0]), max_dist)

    for distance in distances:
        sleigh = ["     ______    ",
                  "_ __(______\_) ",
                  " ___/\____/\__)"]
        if distance <= -14:
            pass
        else:
            if distance < 0:
                sleigh = [sl[-14 - int(distance):] for sl in sleigh]
            else:
                sleigh[0] = " " * int(distance) + sleigh[0]
                sleigh[1] = "_" * int(distance) + sleigh[1]
                sleigh[2] = "_" * (int(distance-1) if distance > 0 else 0) + sleigh[2]

            sleigh_window.addstr(vert_pos, 0, sleigh[0])
            sleigh_window.addstr(vert_pos+1, 0, sleigh[1])
            sleigh_window.addstr(vert_pos+2, 0, sleigh[2])

        vert_pos = vert_pos + RIDER_HEIGHT + empty_cell_size

    return max_dist


def main(stdscr):
    stdscr.nodelay(True)
    # Clear and refresh the screen for a blank canvas
    stdscr.clear()
    stdscr.refresh()

    # Start colors in curses
    curses.start_color()
    curses.init_pair(1, curses.COLOR_CYAN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_BLACK, curses.COLOR_WHITE)

    height, width = stdscr.getmaxyx()
    stdscr.border()

    rider_width = 14
    for rider in riders:
        rider_width = max(rider_width, len(rider._rider))

    name_formatter = '{:^' + str(rider_width) + '}'

    rider_cnt = len(riders)
    empty_cell_size = int((height - 2 - rider_cnt*RIDER_HEIGHT)/(rider_cnt + 1))

    stdscr.vline(1, rider_width+3, curses.ACS_VLINE, height - 2)

    riders_window = stdscr.subwin(height - 2, rider_width, 1, 1)
    redraw_riders(riders_window, empty_cell_size, name_formatter)

    sleigh_window = stdscr.subwin(height - 2, width - rider_width - 7, 1, rider_width+6)
    redraw_sleigh(sleigh_window, empty_cell_size)

    for rider in riders:
        rider.start_boost()

    timestamp = 0
    ride_on = True
    while ride_on:
        time.sleep(0.2)
        for rider in riders:
            rider.time_point(1)
        redraw_riders(riders_window, empty_cell_size, name_formatter)
        sleigh_window.clear()
        dist = redraw_sleigh(sleigh_window, empty_cell_size)

        sleigh_window.addstr(1, 1, "T = " + str(timestamp) + " s.")
        sleigh_window.addstr(2, 1, "D = " + num_formatter_big.format(dist) + " m")

        # Refresh the screen
        stdscr.refresh()
        riders_window.refresh()
        sleigh_window.refresh()

        # Wait for next input

        timestamp = timestamp + 1
        if timestamp % 10 == 0:
            for rider in riders:
                rider.update_acceleration()
        for rider in riders:
            if rider._distance >= 1000:
                ride_on = False
        k = stdscr.getch()
    time.sleep(10)


if __name__ == "__main__":
    for rider in sys.argv[1:]:
        riders.append(Sleigh(rider))
    curses.wrapper(main)

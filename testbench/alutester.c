#include <stdio.h>
#include <ncurses.h>

#include "sim.h"
#include "draw.h"
#include "alutester.h"

static WINDOW *TopWin, *BotWin;


static void create_windows();
static void resize_windows();

static void resize_windows() {

    int xmax, ymax;

    getmaxyx(stdscr, ymax, xmax);

    werase(stdscr);
    wrefresh(stdscr);

    wresize(
        TopWin,
        ymax - (3 * vert_padding) - botwin_height,
        xmax - (2 * hori_padding)
    );

    wresize(
        BotWin,
        botwin_height,
        xmax - (2 * hori_padding)
    );

    mvwin(
        BotWin,
        ymax - (2 * vert_padding) - botwin_height,
        hori_padding
    );

}

static void create_windows() {

    int xmax, ymax;

    getmaxyx(stdscr, ymax, xmax);

    BotWin = newwin(
        botwin_height,
        xmax - (2 * hori_padding),
        ymax - (2 * vert_padding) - botwin_height,
        hori_padding
    );

    TopWin = newwin(
        ymax - (3 * vert_padding) - botwin_height,
        xmax - (2 * hori_padding),
        vert_padding,
        hori_padding
    );


}

int wintest(WINDOW *win) {

    wmove(win, 0, 0);

    wprintw(win, "Hellow");

    wrefresh(win);
}

static void default_mode(struct MenuState *menustate) {

    int event;

    draw_topwin(TopWin, menustate);
    wrefresh(TopWin);

    while ((event = wgetch(TopWin)) != 'q') {
        switch (event) {

            case 'r':
                sim_run_alu(menustate->curcycle,
                            sizeof(struct CycleOutput) * TOTAL_EDGE_CYCLES);

                draw_topwin(TopWin, menustate);
                wrefresh(TopWin);
                break;
            case KEY_RESIZE:
                resize_windows();
                werase(TopWin);
                wrefresh(TopWin);
                draw_topwin(TopWin, menustate);
                wrefresh(TopWin);
                break;

        }
    }

}

int alutester() {

    /* We need the null teminator when writing to the file. */
    char ina[BITWIDTH_INA + 1] = "0000000000000000";
    char inb[BITWIDTH_INB + 1] = "0000000000000001";
    char op[BITWIDTH_OP + 1] = "000";

    ina[BITWIDTH_INA] = inb[BITWIDTH_INB] = op[BITWIDTH_OP] = '\0';

    struct CycleEvent curcycle;
    struct MenuState menustate;

    struct CycleOutput simout[TOTAL_EDGE_CYCLES];

    curcycle.ina = ina;
    curcycle.inb = inb;
    curcycle.op = op;

    curcycle.clkcycle = 0;
    curcycle.out = simout;

    menustate.curbit_ina = 0;
    menustate.curbit_inb = 0;
    menustate.curbit_op = 0;

    menustate.msel = SELECTION_INA;
    menustate.curcycle = &curcycle;

    // sim_run_alu(curcycle, sizeof(simout));

    default_mode(&menustate);

    return 0;

}

int main() {

    int event;

	initscr();
	clear();
	cbreak();
	noecho();
	keypad(stdscr, TRUE);

	if (has_colors())
    	draw_init_colorschemes();

	curs_set(0);

	create_windows();

	keypad(TopWin, TRUE);
	ESCDELAY = 10;

    refresh();
    alutester();

    // wintest(TopWin);
    // wintest(BotWin);

    // while ((event = wgetch(TopWin)) != 'q') {
    //     switch (event) {

    //         case 'j':
    //         case 10:
    //         case KEY_RESIZE:
    //             resize_windows();
    //             wintest(TopWin);
    //             wintest(BotWin);
    //             break;
    //         default:
    //             // resize_windows();
    //             // wintest(TopWin);
    //             // wintest(BotWin);
    //         break;
    //     }
    // }

    // alutester();

	// /*
	//  * TODO: choose between arrowkeys or lightning speed escape
	//  * capture, dumbass !!
	//  * */
	// keypad(Mainwin, TRUE);
	// ESCDELAY = 10;
	// stretch_window(Mainwin);
	// normal_mode();

	endwin();

}

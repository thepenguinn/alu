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

    werase(TopWin);
    wrefresh(TopWin);
    werase(BotWin);
    wrefresh(BotWin);

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

static void bit_flip_mode(WINDOW *win, struct MenuState *menustate) {

    int bitlength;
    int curbit;
    char *bits;
    int event;
    int xcord, ycord;
    int xstart, ystart;

    switch (menustate->msel) {

        case SELECTION_INA:
            curbit = menustate->curbit_ina;
            bits = menustate->curcycle->ina;
            bitlength = BITWIDTH_INA;
            xstart = menustate->xcord_ina;
            ystart = menustate->ycord_ina;
            break;
        case SELECTION_INB:
            curbit = menustate->curbit_inb;
            bits = menustate->curcycle->inb;
            bitlength = BITWIDTH_INB;
            xstart = menustate->xcord_inb;
            ystart = menustate->ycord_inb;
            break;
        case SELECTION_OP:
            curbit = menustate->curbit_op;
            bits = menustate->curcycle->op;
            bitlength = BITWIDTH_OP;
            xstart = menustate->xcord_op;
            ystart = menustate->ycord_op;
            break;
        default:
            return;
    }

    xcord = xstart + curbit + ((curbit + 4) / 4) - 1;
    ycord = ystart;

    draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_CURRENT_BIT);

    wrefresh(win);

    while ((event = wgetch(win))) {

        switch (event) {

            case 'q':
            case KEY_ESCAPE:
            case KEY_RETURN:

                switch (menustate->msel) {

                    case SELECTION_INA:
                        menustate->curbit_ina = curbit;
                        break;
                    case SELECTION_INB:
                        menustate->curbit_inb = curbit;
                        break;
                    case SELECTION_OP:
                        menustate->curbit_op = curbit;
                        break;
                    default:
                        break;
                }
                draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_SELECTED_INA);
                draw_topwin(TopWin, menustate);
                wrefresh(TopWin);
                return;
            case 'j':
            case 'k':
                if (bits[curbit] == '0') {
                    bits[curbit] = '1';
                } else {
                    bits[curbit] = '0';
                }
                // Naive
                draw_topwin(TopWin, menustate);
                draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_CURRENT_BIT);
                wrefresh(TopWin);

                break;
            case 'h':
                if (curbit > 0) {
                    // TODO: make an elment for non-selected bits
                    // draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_SELECTED_INA);
                    draw_topwin(TopWin, menustate);
                    curbit--;
                    xcord = xstart + curbit + ((curbit + 4) / 4) - 1;
                    draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_CURRENT_BIT);
                    wrefresh(win);
                }
                break;
            case 'l':
                if (curbit < bitlength - 1) {
                    // TODO: make an elment for non-selected bits
                    // draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_SELECTED_INA);
                    draw_topwin(TopWin, menustate);
                    curbit++;
                    xcord = xstart + curbit + ((curbit + 4) / 4) - 1;
                    draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_CURRENT_BIT);
                    wrefresh(win);
                }
                break;

            case KEY_RESIZE:
                resize_windows();
                draw_topwin(TopWin, menustate);
                draw_botwin(BotWin, menustate);
                draw_mvwchgat(win, ycord, xcord, 1, ELEMENT_CURRENT_BIT);
                wrefresh(TopWin);
                wrefresh(BotWin);
                break;


        }

    }


}

static void default_mode(struct MenuState *menustate) {

    int event;

    draw_topwin(TopWin, menustate);
    draw_botwin(BotWin, menustate);
    wrefresh(TopWin);
    wrefresh(BotWin);

    while ((event = wgetch(TopWin)) != 'q') {
        switch (event) {

            case 'r':
                sim_run_alu(menustate->curcycle,
                            sizeof(struct CycleOutput) * TOTAL_EDGE_CYCLES);

                menustate->curcycle->clkcycle = 0;
                draw_topwin(TopWin, menustate);
                draw_botwin(BotWin, menustate);
                wrefresh(TopWin);
                wrefresh(BotWin);
                break;
            case 'h':
                if (menustate->msel == SELECTION_INB
                    || menustate->msel == SELECTION_INA) {

                    menustate->msel = SELECTION_OP;
                    draw_topwin(TopWin, menustate);
                    draw_botwin(BotWin, menustate);
                    wrefresh(TopWin);
                    wrefresh(BotWin);
                }
                break;
            case 'l':
                if (menustate->msel == SELECTION_OP) {
                    menustate->msel = SELECTION_INB;
                    draw_topwin(TopWin, menustate);
                    draw_botwin(BotWin, menustate);
                    wrefresh(TopWin);
                    wrefresh(BotWin);
                }
                break;
            case 'j':
                if (menustate->msel == SELECTION_INA) {
                    menustate->msel = SELECTION_INB;
                    draw_topwin(TopWin, menustate);
                    draw_botwin(BotWin, menustate);
                    wrefresh(TopWin);
                    wrefresh(BotWin);
                }
                break;
            case 'k':
                if (menustate->msel == SELECTION_INB) {
                    menustate->msel = SELECTION_INA;
                    draw_topwin(TopWin, menustate);
                    draw_botwin(BotWin, menustate);
                    wrefresh(TopWin);
                    wrefresh(BotWin);
                }
                break;
            case 'n':
                // TODO: There is bug here ! we shouldn't be needing that - 1
                if (menustate->curcycle->clkcycle < TOTAL_EDGE_CYCLES - 1) {
                    (menustate->curcycle->clkcycle)++;
                    draw_topwin(TopWin, menustate);
                    draw_botwin(BotWin, menustate);
                    wrefresh(TopWin);
                    wrefresh(BotWin);
                }
                break;
            case 'p':
                if (menustate->curcycle->clkcycle > 0) {
                    (menustate->curcycle->clkcycle)--;
                    draw_topwin(TopWin, menustate);
                    draw_botwin(BotWin, menustate);
                    wrefresh(TopWin);
                    wrefresh(BotWin);
                }
                break;
            case KEY_RETURN:
                bit_flip_mode(TopWin, menustate);
                break;
            case KEY_RESIZE:
                resize_windows();
                draw_topwin(TopWin, menustate);
                draw_botwin(BotWin, menustate);
                wrefresh(TopWin);
                wrefresh(BotWin);
                break;

        }
    }

}

int alutester() {

    /* We need the null teminator when writing to the file. */
    char ina[BITWIDTH_INA + 1] = "0000000000000000";
    char inb[BITWIDTH_INB + 1] = "0000000000000000";
    char op[BITWIDTH_OP + 1] = "000";

    ina[BITWIDTH_INA] = inb[BITWIDTH_INB] = op[BITWIDTH_OP] = '\0';

    struct CycleEvent curcycle;
    struct MenuState menustate;

    char simout[TOTAL_EDGE_CYCLES * sizeof(struct CycleOutput)] =
        "xxxxxxxxxxxxxxxxxx";
    // struct CycleOutput simout[TOTAL_EDGE_CYCLES] =

    curcycle.ina = ina;
    curcycle.inb = inb;
    curcycle.op = op;

    curcycle.clkcycle = 0;
    curcycle.out = (struct CycleOutput *)simout;

    menustate.curbit_ina = BITWIDTH_INA - 1;
    menustate.curbit_inb = BITWIDTH_INB - 1;
    menustate.curbit_op = BITWIDTH_OP - 1;

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

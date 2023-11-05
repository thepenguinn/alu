#include <stdio.h>
#include <ncurses.h>

#include "sim.h"
#include "draw.h"

/*
••••••••••••••••••••••••
─ ━ │ ┃ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋ ┌ ┍ ┎ ┏
U+251x    ┐ ┑ ┒ ┓ └ ┕ ┖ ┗ ┘ ┙ ┚ ┛ ├ ┝ ┞ ┟
U+252x    ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┬ ┭ ┮ ┯
U+253x    ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻ ┼ ┽ ┾ ┿
U+254x    ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╌ ╍ ╎ ╏
U+255x    ═ ║ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟
U+256x    ╠ ╡ ╢ ╣ ╤ ╥ ╦ ╧ ╨ ╩ ╪ ╫ ╬ ╭ ╮ ╯
U+257x    ╰ ╱╳ ╲ ╳ ╴ ╵ ╶ ╷ ╸ ╹ ╺ ╻ ╼ ╽ ╾ ╿
U+257x    ╰ ╱ ╲ ╳ ╴ ╵ ╶ ╷ ╸ ╹ ╺ ╻ ╼ ╽ ╾ ╿
Notes            ╳
  │
──┼────
  │
  */

static const char *Symbol_chars[CHAR_END] = {
    [CHAR_MINUS] = "─",
};

static const char *Hex_colors[COLOR_END] = {
	[COLOR_BRT_PINK]     = "#EF6FF9",
	[COLOR_BRT_YELLOW]   = "#EBF980",
	[COLOR_BRT_WHITE]    = "#DDDDDD",
	[COLOR_BRT_GREY]     = "#616162",
	[COLOR_BRT_GREEN]    = "#10AF76",
	[COLOR_BRT_VIOLET]   = "#7571F9",
	[COLOR_DIM_PINK]     = "#AD58B3",
	[COLOR_DIM_WHITE]    = "#979797",
	[COLOR_DIM_GREY]     = "#3C3C3A",
	[COLOR_DIM_GREEN]    = "#036B46",
	[COLOR_DIM_VIOLET]   = "#514CC0",
	[COLOR_DIM_BROWN]    = "#3C3C3A",
};

static int16_t Color_pairs[PAIR_END][2] = {
    [PAIR_BRT_WHITE_DEF_BG]  = {COLOR_BRT_WHITE, COLOR_DEFAULT_BG},
    [PAIR_DIM_WHITE_DEF_BG]  = {COLOR_DIM_WHITE, COLOR_DEFAULT_BG},
    [PAIR_DIM_BROWN_DEF_BG]  = {COLOR_DIM_BROWN, COLOR_DEFAULT_BG},
};

static int Color_schemes[SCHEME_END][ELEMENT_END] = {
    [SCHEME_DEFAULT] = {
        [ELEMENT_WIN_SEP]        = ColorPair(PAIR_DIM_BROWN_DEF_BG),
        [ELEMENT_ALU_OUT]        = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELEMENT_NORMAL_INA]     = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELEMENT_SELECTED_INA]   = ColorPair(PAIR_BRT_WHITE_DEF_BG),
        [ELEMENT_NORMAL_INB]     = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELEMENT_SELECTED_INB]   = ColorPair(PAIR_BRT_WHITE_DEF_BG),
        [ELEMENT_NORMAL_OP]      = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELEMENT_SELECTED_OP]    = ColorPair(PAIR_BRT_WHITE_DEF_BG),
        [ELEMENT_NORMAL_CLK]     = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELEMENT_SELECTED_CLK]   = ColorPair(PAIR_BRT_WHITE_DEF_BG),
        [ELEMENT_CURRENT_BIT]    = ColorPair(PAIR_BRT_WHITE_DEF_BG) | A_BOLD,
    }
};


void draw_init_colorschemes(void) {

	const char *hexstring;
	int r, g, b;
	int i;

	start_color();
	use_default_colors();

	/* initializing colors */

	for (i = 0;i < COLOR_END; i++) {
		hexstring = Hex_colors[i];
		if (*hexstring == '#')
			hexstring++;

		sscanf(hexstring, "%02x%02x%02x", &r, &g, &b);
		init_color(i, r*1000/255, g*1000/255, b*1000/255);
	}

	/* initializing color pairs */

	/*
	 * Since we are using use_default_colors() from ncurses library, the zeroth
	 * pair doesn't seems to be overriden by assigning a new pair to it.
	 *
     * And we dont want to change 0-15 colors,
	 * So we will start from 16
	 * */

	for (i = 0;i < PAIR_END;i++) {
		init_pair(i + 1, Color_pairs[i][0], Color_pairs[i][1]);
    }

}

static void draw_bits(WINDOW *win, char *bits, int bitsize) {

    int tmp = bitsize / 4;
    int mod = bitsize % 4;
    int ismod = !mod;

    /* Duff's Device,.. I was bored... */
    switch (mod) {
        do { wprintw(win, " ");
            case 0: wprintw(win, "%c", *bits++);
            case 3: wprintw(win, "%c", *bits++);
            case 2: wprintw(win, "%c", *bits++);
            case 1: wprintw(win, "%c", *bits++);
        } while (ismod < tmp--);
    }

}

void draw_topwin(WINDOW *win, struct MenuState *menustate) {

    int xmax, ymax;
    struct CycleOutput *cout = menustate->curcycle->out;

    getmaxyx(win, ymax, xmax);

    xmax--;
    ymax--;

    menustate->xcord_ina = xmax - BITWIDTH_INA - (BITWIDTH_INA / 4) + 1;
    menustate->ycord_ina = ymax / 2;

    menustate->xcord_inb = xmax - BITWIDTH_INB - (BITWIDTH_INB / 4) + 1;
    menustate->ycord_inb = ymax;

    menustate->xcord_op = 1;
    menustate->ycord_op = ymax;

    if (menustate->msel == SELECTION_INA) {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_SELECTED_INA]);
    } else {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_INA]);
    }

    wmove(win, menustate->ycord_ina, menustate->xcord_ina);
    draw_bits(win, menustate->curcycle->ina, BITWIDTH_INA);

    if (menustate->msel == SELECTION_INB) {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_SELECTED_INB]);
    } else {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_INB]);
    }

    wmove(win, menustate->ycord_inb, menustate->xcord_inb);
    draw_bits(win, menustate->curcycle->inb, BITWIDTH_INB);

    if (menustate->msel == SELECTION_OP) {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_SELECTED_OP]);
    } else {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_OP]);
    }

    wmove(win, ymax, 1);
    draw_bits(win, menustate->curcycle->op, BITWIDTH_OP);


    if (menustate->msel == SELECTION_CLK) {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_SELECTED_CLK]);
    } else {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_CLK]);
    }

    wmove(win, 1, 1);
    draw_bits(win, cout->clk, BITWIDTH_CLK);

    wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_OP]);

}

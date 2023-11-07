#include <stdio.h>
#include <ncurses.h>

#include "sim.h"
#include "draw.h"

/*
 * ● ○
ᴀ	ʙ	ᴄ	ᴅ	ᴇ	ꜰ	ɢʜ	ɪ	ᴊ	ᴋ	ʟ	ᴍ	ɴ	ᴏ	ᴘ	ꞯ	ʀ	ꜱ	ᴛ	ᴜ	ᴠ	ᴡ	–	ʏ	ᴢ
superscript		𐞄					𐞒	𐞖	ᶦ			ᶫ		ᶰ				𐞪			ᶸ				𐞲
overscript							◌ᷛ					◌ᷞ	◌ᷟ	◌ᷡ				◌ᷢ
 *
 *◂▸◄►►▷
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
ᴀ	ʙ	ᴄ	ᴅ	ᴇ	ꜰ	ɢʜ	ɪ	ᴊ	ᴋ	ʟ	ᴍ	ɴ	ᴏ	ᴘ	ꞯ	ʀ	ꜱ	ᴛ	ᴜ	ᴠ	ᴡ	–	ʏ	ᴢ
superscript		𐞄					𐞒	𐞖	ᶦ			ᶫ		ᶰ				𐞪			ᶸ				𐞲
overscript							◌ᷛ					◌ᷞ	◌ᷟ	◌ᷡ				◌ᷢ
  */

static const char *Symbol_chars[CHAR_END] = {
    [CHAR_MINUS] = "─",
    [CHAR_RIGHT_TRIANGLE] = "▸",
    [CHAR_LEFT_TRIANGLE] = "◂",
    // [CHAR_RIGHT_TRIANGLE] = "▷",
    // [CHAR_LEFT_TRIANGLE] = "◁",
    [CHAR_SUM] = "ꜱᴜʙ",
    // [CHAR_SUM] = "ꜱᴜʙ",
    // [CHAR_SUM] = "ɴᴀɴᴅ",
    // [CHAR_SUM] = "ᴀɴᴅ",
    // [CHAR_SUM] = "ꜱᴜᴍ",
    // [CHAR_SUM] = "ɴᴏʀ",
    // [CHAR_SUM] = "ɴᴏᴛ",
    // [CHAR_SUM] = "ᴏʀ",
    // [CHAR_SUM] = "xᴏʀ",
    // [CHAR_SUM] = "xɴᴏʀ",
    // [CHAR_SUM] = "ꜱᴜᴍ",
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

/*
 * (0 <= (x)) * will make sure that we are adding COLOR_MOD_START
 * only to positive (x)s, because COLOR_DEFAULT_BG is -1
 * */

#define GCOL(x) ((x) + ((0 <= (x)) * COLOR_MOD_START))

static int16_t Color_pairs[PAIR_END][2] = {
    [PAIR_BRT_WHITE_DEF_BG]  = {GCOL(COLOR_BRT_WHITE), GCOL(COLOR_DEFAULT_BG)},
    [PAIR_DIM_WHITE_DEF_BG]  = {GCOL(COLOR_DIM_WHITE), GCOL(COLOR_DEFAULT_BG)},
    [PAIR_DIM_BROWN_DEF_BG]  = {GCOL(COLOR_DIM_BROWN), GCOL(COLOR_DEFAULT_BG)},
    [PAIR_BRT_GREY_DEF_BG]   = {GCOL(COLOR_BRT_GREY),  GCOL(COLOR_DEFAULT_BG)},
    [PAIR_DIM_GREY_DEF_BG]   = {GCOL(COLOR_DIM_GREY),  GCOL(COLOR_DEFAULT_BG)},
};

#undef GCOL

static int Color_schemes[SCHEME_END][ELEMENT_END] = {
    [SCHEME_DEFAULT] = {
        [ELEMENT_WIN_SEP]        = ColorPair(PAIR_DIM_BROWN_DEF_BG),
        [ELEMENT_ALU_OUT]        = ColorPair(PAIR_DIM_WHITE_DEF_BG) | A_BOLD,

        [ELEMENT_NORMAL_INA]     = ColorPair(PAIR_BRT_GREY_DEF_BG),
        [ELEMENT_SELECTED_INA]   = ColorPair(PAIR_DIM_WHITE_DEF_BG),

        [ELEMENT_NORMAL_INB]     = ColorPair(PAIR_BRT_GREY_DEF_BG),
        [ELEMENT_SELECTED_INB]   = ColorPair(PAIR_DIM_WHITE_DEF_BG),

        [ELEMENT_NORMAL_OP]      = ColorPair(PAIR_BRT_GREY_DEF_BG),
        [ELEMENT_SELECTED_OP]    = ColorPair(PAIR_DIM_WHITE_DEF_BG),

        [ELEMENT_NORMAL_CLK]     = ColorPair(PAIR_BRT_GREY_DEF_BG),
        [ELEMENT_SELECTED_CLK]   = ColorPair(PAIR_DIM_WHITE_DEF_BG),

        [ELEMENT_CURRENT_BIT]    = ColorPair(PAIR_BRT_WHITE_DEF_BG),
        [ELEMENT_YES_TRIANGLE]   = ColorPair(PAIR_BRT_WHITE_DEF_BG),
        [ELEMENT_NO_TRIANGLE]    = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELMENT_NORMAL_OPCODE]   = ColorPair(PAIR_DIM_WHITE_DEF_BG),
        [ELMENT_SELECTED_OPCODE] = ColorPair(PAIR_BRT_WHITE_DEF_BG),
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
		init_color(i + COLOR_MOD_START, r*1000/255, g*1000/255, b*1000/255);
	}

	/* initializing color pairs */

	/*
	 * Since we are using use_default_colors() from ncurses library, the zeroth
	 * pair doesn't seems to be overriden by assigning a new pair to it.
	 *
     * And we dont want to change 0-15 colors,
	 * So we will start from 16, which is COLOR_MOD_START
	 * */

	for (i = 0;i < PAIR_END;i++) {
		init_pair(i + COLOR_MOD_START, Color_pairs[i][0], Color_pairs[i][1]);
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

void draw_mvwchgat(WINDOW *win, int ycord, int xcord, int n, enum ColorElements attridx) {

    wmove(win, ycord, xcord);

    wchgat(win, n, Color_schemes[SCHEME_DEFAULT][attridx], 0, NULL);

}

void draw_botwin(WINDOW *win, struct MenuState *menustate) {

    int xmax, ymax;
    int i;
    struct CycleEvent *cevent = menustate->curcycle;

    getmaxyx(win, ymax, xmax);

    ymax--;
    xmax--;

    wmove(win, 1, 0);

    wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_WIN_SEP]);

    for (i = 0; i <= xmax; i++) {
        wprintw(win, "%s", Symbol_chars[CHAR_MINUS]);
    }

    wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_ALU_OUT]);

    // wmove(win, 3, xmax - BITWIDTH_ALUOUT - BITWIDTH_ALUOUT - 3 - (BITWIDTH_ALUOUT / 4));
    wmove(win, 3, xmax - BITWIDTH_ALUOUT - (BITWIDTH_ALUOUT / 4));

    // wprintw(win, "%s", "●   ○ ● ○ ○   ○ ○ ● ○   ○ ● ○ ○   ● ○ ○ ●");
    draw_bits(win, (cevent->out + cevent->clkcycle)->aluout, BITWIDTH_ALUOUT);

}

void draw_topwin(WINDOW *win, struct MenuState *menustate) {

    int xmax, ymax;
    struct CycleEvent *cevent = menustate->curcycle;

    getmaxyx(win, ymax, xmax);

    xmax--;
    ymax--;

    menustate->xcord_ina = xmax - BITWIDTH_INA - (BITWIDTH_INA / 4) + 1;
    menustate->ycord_ina = ymax - 4;

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

    wmove(win, menustate->ycord_op, menustate->xcord_op);
    draw_bits(win, menustate->curcycle->op, BITWIDTH_OP);

    // wmove(win, ymax - 2, 0);

    // wprintw(win, "%s", "○ ○ ●");
    // wprintw(win, " %s %s %s", Symbol_chars[CHAR_LEFT_TRIANGLE],
    //         Symbol_chars[CHAR_SUM], Symbol_chars[CHAR_RIGHT_TRIANGLE]);

    if (menustate->msel == SELECTION_CLK) {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_SELECTED_CLK]);
    } else {
        wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_CLK]);
    }

    wmove(win, 1, 1);
    draw_bits(win, (cevent->out + cevent->clkcycle)->clk, BITWIDTH_CLK);

    wattron(win, Color_schemes[SCHEME_DEFAULT][ELEMENT_NORMAL_OP]);

}

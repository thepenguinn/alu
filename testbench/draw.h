static int botwin_height = 5;
static int hori_padding = 3;
static int vert_padding = 1;

/*
 * we are using use_default_colors() from ncurses library
 * */

#define COLOR_DEFAULT_BG  -1
#define COLOR_DEFAULT_FG  -1

/*
 * We don't want to modify the colors from 0-15, when we initialize
 * colors and color pairs.
 * So, our colors and color pair ids will start from 16
 * */
#define COLOR_MOD_START 16

/*
 * Since we are using use_default_colors() from ncurses library, the zeroth
 * pair doesn't seems to be overriden by assigning a new pair to it.
 *
 * So instead of changing the zeroth pair we will start from 16
 * 16 because we don't want to mess up other 0-15 colors.
 * */

#define ColorPair(x) COLOR_PAIR((x) + COLOR_MOD_START)


enum ColorHex {

	COLOR_BRT_PINK,
	COLOR_BRT_YELLOW,
	COLOR_BRT_WHITE,
	COLOR_BRT_GREY,
	COLOR_BRT_GREEN,
	COLOR_BRT_VIOLET,
	COLOR_DIM_PINK,
	COLOR_DIM_WHITE,
	COLOR_DIM_GREY,
	COLOR_DIM_GREEN,
	COLOR_DIM_VIOLET,
	COLOR_DIM_BROWN,
    COLOR_END

};

enum SymbolChars {

    CHAR_MINUS,
    CHAR_RIGHT_TRIANGLE,
    CHAR_LEFT_TRIANGLE,
    CHAR_SUM,
    CHAR_END

};

enum ColorPairs {

    PAIR_BRT_WHITE_DEF_BG,
    PAIR_BRT_GREY_DEF_BG,
    PAIR_DIM_GREY_DEF_BG,
    PAIR_DIM_WHITE_DEF_BG,
    PAIR_DIM_BROWN_DEF_BG,
    PAIR_END

};

enum ColorSchemes {

    SCHEME_DEFAULT,
    SCHEME_END

};

enum ColorElements {

    ELEMENT_WIN_SEP,
    ELEMENT_ALU_OUT,
    ELEMENT_NORMAL_INA,
    ELEMENT_SELECTED_INA,
    ELEMENT_NORMAL_INB,
    ELEMENT_SELECTED_INB,
    ELEMENT_NORMAL_OP,
    ELEMENT_SELECTED_OP,
    ELEMENT_NORMAL_CLK,
    ELEMENT_SELECTED_CLK,
    ELEMENT_CURRENT_BIT,
    ELEMENT_YES_TRIANGLE,
    ELEMENT_NO_TRIANGLE,
    ELMENT_NORMAL_OPCODE,
    ELMENT_SELECTED_OPCODE,
    ELEMENT_END

};

enum MenuSelection {

    SELECTION_INA,
    SELECTION_INB,
    SELECTION_OP,
    SELECTION_CLK

};

struct MenuState;

struct MenuState {

    enum MenuSelection msel;
    int curbit_ina;
    int curbit_inb;
    int curbit_op;

    /* Leftmost bit cordinates */
    int xcord_ina;
    int ycord_ina;

    int xcord_inb;
    int ycord_inb;

    int xcord_op;
    int ycord_op;

    struct CycleEvent *curcycle;

};

void draw_init_colorschemes(void);
void draw_topwin(WINDOW *win, struct MenuState *menustate);
void draw_botwin(WINDOW *win, struct MenuState *menustate);
void draw_mvwchgat(WINDOW *win, int ycord, int xcord, int n, enum ColorElements attridx);

from pygments.style import Style
from pygments.token import (
    Comment,
    Error,
    Generic,
    Keyword,
    Literal,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
    Text,
    Token,
    _TokenType,
)

class CatppuccinmonolightStyle(Style):

    """Catppuccin MonoLight pygments style."""

    name = "catppuccinmonolight"

    background_color =             "#1f1f1f"
    line_number_background_color = "#181818"
    line_number_color =            "#d6d6d6"

    styles = {

        Token:                 "#0a0a0a",
        Text:                  "#0a0a0a",
        Error:                 "#000000",
        Keyword:               "#101010",
        Keyword.Constant:      "#383838",
        Keyword.Declaration:   "#1b1b1b",
        Keyword.Namespace:     "#323232",
        Keyword.Pseudo:        "#101010",
        Keyword.Reserved:      "#101010",
        Keyword.Type:          "#1b1b1b",
        Name:                  "#545454",
        Name.Attribute:        "#1b1b1b",
        Name.Constant:         "#515151",
        Name.Decorator:        "#1b1b1b",
        Name.Function:         "#1b1b1b",
        Name.Function.Magic:   "#414141",
        Name.Label:            "#1b1b1b",
        Name.Tag:              "#101010",
        Literal:               "#0a0a0a",
        String:                "#3d3d3d",
        Number:                "#545454",
        Punctuation:           "#0a0a0a",
        Operator:              "#414141",
        # Comment:             "#5a5a5a",
        Comment:               "#707070",
        Generic.Heading:       "#1b1b1b",
    }

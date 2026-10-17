import from "@jac/mobui" { StyleSheet }

glob DARK: dict = {
    "bg": "#f4f7f6",
    "surface": "#ffffff",
    "border": "#e2e9e6",
    "text": "#17332d",
    "muted": "#71847f",
    "accent": "#087f68",
    "accentText": "#ffffff"
};


def:pub buildStyles(C: dict) -> any {
    return StyleSheet.create({
        "screen": {"flex": 1, "backgroundColor": C["bg"]},
        "screenContent": {
            "flexGrow": 1,
            "justifyContent": "center",
            "paddingTop": 64,
            "paddingBottom": 36,
            "paddingHorizontal": 26,
            "gap": 28
        },
        "brandMark": {
            "width": 44,
            "height": 44,
            "borderRadius": 15,
            "backgroundColor": C["accent"],
            "alignItems": "center",
            "justifyContent": "center"
        },
        "brandPlus": {"color": C["accent"], "fontSize": 27, "fontWeight": "bold"},
        "hero": {"gap": 8},
        "title": {"fontSize": 31, "fontWeight": "bold", "color": C["text"]},
        "subtitle": {"fontSize": 15, "lineHeight": 23, "color": C["muted"]},
        "loginPanel": {
            "padding": 22,
            "gap": 14,
            "borderRadius": 22,
            "borderWidth": 1,
            "borderColor": C["border"],
            "backgroundColor": C["surface"]
        },
        "panelTitle": {"fontSize": 18, "fontWeight": "bold", "color": C["text"]},
        "primaryButton": {
            "marginTop": 8,
            "paddingVertical": 16,
            "borderRadius": 13,
            "backgroundColor": C["accent"],
            "alignItems": "center"
        },
        "buttonLabel": {"fontSize": 15, "fontWeight": "bold", "color": C["accentText"]},
        "secondaryButton": {
            "paddingVertical": 16,
            "borderRadius": 13,
            "borderWidth": 1,
            "borderColor": C["border"],
            "backgroundColor": C["surface"],
            "alignItems": "center"
        },
        "secondaryLabel": {"fontSize": 15, "fontWeight": "bold", "color": C["text"]},
        "footer": {"fontSize": 13, "color": C["muted"], "textAlign": "center"},
        "appFrame": {"flex": 1},
        "pageBody": {"flex": 1},
        "pageContent": {"paddingTop": 58, "paddingBottom": 28, "paddingHorizontal": 22, "gap": 24},
        "topBar": {"flexDirection": "row", "alignItems": "center", "justifyContent": "space-between"},
        "brandName": {"fontSize": 22, "fontWeight": "bold", "color": C["text"]},
        "roleLabel": {"fontSize": 12, "color": C["muted"]},
        "switchButton": {"paddingVertical": 9, "paddingHorizontal": 12, "borderRadius": 10, "borderWidth": 1, "borderColor": C["border"]},
        "switchLabel": {"fontSize": 12, "fontWeight": "bold", "color": C["accent"]},
        "pageHeading": {"gap": 5, "paddingTop": 12},
        "placeholderCard": {
            "padding": 22,
            "gap": 12,
            "borderRadius": 20,
            "borderWidth": 1,
            "borderColor": C["border"],
            "backgroundColor": C["surface"]
        },
        "cardAccent": {"width": 34, "height": 4, "borderRadius": 4, "backgroundColor": C["accent"]},
        "placeholderText": {"fontSize": 15, "lineHeight": 23, "color": C["muted"]},
        "infoCard": {"padding": 18, "gap": 7, "borderRadius": 16, "backgroundColor": "#e8f2ef"},
        "infoTitle": {"fontSize": 14, "fontWeight": "bold", "color": C["text"]},
        "bottomBar": {
            "flexDirection": "row",
            "justifyContent": "space-around",
            "alignItems": "center",
            "paddingTop": 10,
            "paddingBottom": 22,
            "paddingHorizontal": 8,
            "borderTopWidth": 1,
            "borderTopColor": C["border"],
            "backgroundColor": C["surface"]
        },
        "tabButton": {"flex": 1, "alignItems": "center", "justifyContent": "center", "gap": 6, "paddingVertical": 4},
        "tabIndicator": {"width": 22, "height": 3, "borderRadius": 3, "backgroundColor": C["accent"]},
        "tabIndicatorOff": {"width": 22, "height": 3, "borderRadius": 3, "backgroundColor": "transparent"},
        "tabLabel": {"fontSize": 11, "color": C["muted"], "textAlign": "center"},
        "tabLabelActive": {"fontSize": 11, "fontWeight": "bold", "color": C["accent"], "textAlign": "center"}
    });
}

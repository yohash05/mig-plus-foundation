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
        "tabLabelActive": {"fontSize": 11, "fontWeight": "bold", "color": C["accent"], "textAlign": "center"},
        "communityIntro": {"gap": 7, "paddingTop": 10, "paddingBottom": 4},
        "supportChoice": {"padding": 21, "gap": 9, "borderRadius": 20, "backgroundColor": C["accent"]},
        "communityChoice": {"padding": 21, "gap": 9, "borderRadius": 20, "borderWidth": 1, "borderColor": C["border"], "backgroundColor": C["surface"]},
        "choiceEyebrow": {"fontSize": 10, "fontWeight": "bold", "color": "#c5e8dd"},
        "choiceTitle": {"fontSize": 18, "fontWeight": "bold", "color": C["text"]},
        "choiceDescription": {"fontSize": 14, "lineHeight": 21, "color": C["muted"]},
        "chatHeader": {"flexDirection": "row", "alignItems": "center", "gap": 14, "paddingTop": 8},
        "backButton": {"paddingVertical": 9, "paddingHorizontal": 12, "borderRadius": 10, "borderWidth": 1, "borderColor": C["border"], "backgroundColor": C["surface"]},
        "backLabel": {"fontSize": 13, "fontWeight": "bold", "color": C["accent"]},
        "chatTitleBlock": {"flex": 1, "gap": 3},
        "chatTitle": {"fontSize": 17, "fontWeight": "bold", "color": C["text"]},
        "messageList": {"gap": 13, "paddingTop": 8, "paddingBottom": 18},
        "messageRow": {"alignItems": "flex-start"},
        "messageRowMine": {"alignItems": "flex-end"},
        "messageBubble": {"maxWidth": "88%", "padding": 14, "gap": 6, "borderRadius": 16, "borderWidth": 1, "borderColor": C["border"], "backgroundColor": C["surface"]},
        "messageBubbleMine": {"maxWidth": "88%", "padding": 14, "gap": 6, "borderRadius": 16, "backgroundColor": "#e4f2ed"},
        "senderLabel": {"fontSize": 12, "fontWeight": "bold", "color": C["accent"]},
        "senderLabelMine": {"fontSize": 12, "fontWeight": "bold", "color": C["text"]},
        "messageText": {"fontSize": 14, "lineHeight": 21, "color": C["text"]},
        "messageTextMine": {"fontSize": 14, "lineHeight": 21, "color": C["text"]},
        "composer": {"flexDirection": "row", "alignItems": "center", "gap": 9, "paddingTop": 12, "paddingBottom": 18, "paddingHorizontal": 15, "borderTopWidth": 1, "borderTopColor": C["border"], "backgroundColor": C["surface"]},
        "messageInput": {"flex": 1, "paddingVertical": 12, "paddingHorizontal": 14, "borderRadius": 13, "borderWidth": 1, "borderColor": C["border"], "backgroundColor": C["bg"], "color": C["text"], "fontSize": 14},
        "sendButton": {"paddingVertical": 13, "paddingHorizontal": 17, "borderRadius": 13, "backgroundColor": C["accent"]},
        "sendLabel": {"fontSize": 14, "fontWeight": "bold", "color": C["accentText"]}
    });
}

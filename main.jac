import from "@jac/mobui" {
    View,
    Text,
    Pressable,
    ScrollView,
    TextInput,
    useWindowDimensions
}
import from .theme { buildStyles }

glob styles = buildStyles({
    "bg": "#f4f7f6",
    "surface": "#ffffff",
    "border": "#e2e9e6",
    "text": "#17332d",
    "muted": "#71847f",
    "accent": "#087f68",
    "accentText": "#ffffff"
});


def:pub app -> JsxElement {
    has role: str = "",
        active_tab: str = "Home",
        active_chat: str = "",
        draft_message: str = "",
        chat_messages: list[dict] = [];

    viewport = useWindowDimensions();

    def choose_role(selected: str) {
        role = selected;
        active_tab = "Home";
    }

    def select_tab(selected: str) {
        active_tab = selected;
        active_chat = "";
    }

    def open_chat(kind: str) {
        active_chat = kind;
        if kind == "Worker Community Chat" {
            chat_messages = [
                {"sender": "Amina", "text": "Has anyone renewed a work visa in Dubai recently? What documents did they ask for?", "mine": False},
                {"sender": "Ravi", "text": "The community centre is hosting a free-language meetup on Saturday. Anyone going?", "mine": False},
                {"sender": "Lina", "text": "I renewed last month. Bring your passport, contract, and the appointment confirmation.", "mine": False}
            ];
        } else {
            chat_messages = [
                {"sender": "Embassy Support", "text": "Welcome to Direct Embassy Support. Send us your question and our team will assist you.", "mine": False}
            ];
        }
        draft_message = "";
    }

    def send_message {
        clean = draft_message.strip();
        if clean {
            chat_messages = chat_messages + [{"sender": "You", "text": clean, "mine": True}];
            draft_message = "";
        }
    }

    worker_tabs: list[str] = ["Home", "Community", "Medi AI"];
    embassy_tabs: list[str] = ["Home", "Triage Dashboard", "Broadcast"];
    tabs = worker_tabs if role == "Worker" else embassy_tabs;

    return <View style={[styles.screen, {height: viewport.height}]}>
        {(
            <ScrollView style={styles.screen} contentContainerStyle={styles.screenContent}>
                <View style={styles.brandMark}>
                    <Text style={styles.brandPlus}>+</Text>
                </View>
                <View style={styles.hero}>
                    <Text style={styles.title}>Mig<Text style={styles.brandPlus}>+</Text></Text>
                    <Text style={styles.subtitle}>Support for every step away from home.</Text>
                </View>
                <View style={styles.loginPanel}>
                    <Text style={styles.panelTitle}>Choose your workspace</Text>
                    <Text style={styles.subtitle}>Select how you want to use Mig+.</Text>
                    <Pressable style={styles.primaryButton} onPress={lambda { choose_role("Worker"); }}>
                        <Text style={styles.buttonLabel}>Login as Worker</Text>
                    </Pressable>
                    <Pressable style={styles.secondaryButton} onPress={lambda { choose_role("Embassy"); }}>
                        <Text style={styles.secondaryLabel}>Login as Embassy</Text>
                    </Pressable>
                </View>
                <Text style={styles.footer}>A connected support network, wherever you are.</Text>
            </ScrollView>
        ) if role == "" else <View style={styles.appFrame}>
            <ScrollView style={styles.pageBody} contentContainerStyle={styles.pageContent}>
                <View style={styles.topBar}>
                    <View>
                        <Text style={styles.brandName}>Mig<Text style={styles.brandPlus}>+</Text></Text>
                        <Text style={styles.roleLabel}>{role} workspace</Text>
                    </View>
                    <Pressable style={styles.switchButton} onPress={lambda { role = ""; }}>
                        <Text style={styles.switchLabel}>Switch role</Text>
                    </Pressable>
                </View>
                {if active_tab == "Community" and role == "Worker" {
                    if active_chat == "" {
                        <View style={styles.communityIntro}>
                            <Text style={styles.title}>Community</Text>
                            <Text style={styles.subtitle}>Find support from fellow workers or contact your embassy directly.</Text>
                        </View>
                        <Pressable style={styles.supportChoice} onPress={lambda { open_chat("Direct Embassy Support"); }}>
                            <Text style={styles.choiceEyebrow}>PRIVATE SUPPORT</Text>
                            <Text style={styles.choiceTitle}>Direct Embassy Support</Text>
                            <Text style={styles.choiceDescription}>Start a private conversation with embassy staff.</Text>
                        </Pressable>
                        <Pressable style={styles.communityChoice} onPress={lambda { open_chat("Worker Community Chat"); }}>
                            <Text style={styles.choiceEyebrow}>PEER COMMUNITY</Text>
                            <Text style={styles.choiceTitle}>Worker Community Chat</Text>
                            <Text style={styles.choiceDescription}>Connect with workers and share local advice.</Text>
                        </Pressable>
                    } else {
                        <View style={styles.chatHeader}>
                            <Pressable style={styles.backButton} onPress={lambda { active_chat = ""; }}>
                                <Text style={styles.backLabel}>Back</Text>
                            </Pressable>
                            <View style={styles.chatTitleBlock}>
                                <Text style={styles.chatTitle}>{active_chat}</Text>
                                <Text style={styles.roleLabel}>{"Mig+ " + ("Community" if active_chat == "Worker Community Chat" else "Embassy Support")}</Text>
                            </View>
                        </View>
                        <View style={styles.messageList}>
                            {for (idx, message) in enumerate(chat_messages) {
                                <View key={str(idx)} style={styles.messageRow if not (message["mine"] as bool) else styles.messageRowMine}>
                                    <View style={styles.messageBubble if not (message["mine"] as bool) else styles.messageBubbleMine}>
                                        <Text style={styles.senderLabel if not (message["mine"] as bool) else styles.senderLabelMine}>{message["sender"] as str}</Text>
                                        <Text style={styles.messageText if not (message["mine"] as bool) else styles.messageTextMine}>{message["text"] as str}</Text>
                                    </View>
                                </View>
                            }}
                        </View>
                    }
                } else {
                    <View style={styles.pageHeading}>
                        <Text style={styles.title}>{active_tab}</Text>
                        <Text style={styles.subtitle}>{"Your " + role.lower() + " workspace is ready."}</Text>
                    </View>
                    <View style={styles.placeholderCard}>
                        <View style={styles.cardAccent} />
                        <Text style={styles.panelTitle}>{active_tab}</Text>
                        <Text style={styles.placeholderText}>This space is ready for your {active_tab} tools and updates.</Text>
                    </View>
                    <View style={styles.infoCard}>
                        <Text style={styles.infoTitle}>Mig+ support</Text>
                        <Text style={styles.subtitle}>More features for the Mig+ community are coming soon.</Text>
                    </View>
                }}
            </ScrollView>
            {if active_chat != "" {
                <View style={styles.composer}>
                    <TextInput
                        style={styles.messageInput}
                        value={draft_message}
                        placeholder="Write a message..."
                        placeholderTextColor="#71847f"
                        onChangeText={lambda (text: str) { draft_message = text; }}
                        onSubmitEditing={lambda { send_message(); }}
                    />
                    <Pressable style={styles.sendButton} onPress={lambda { send_message(); }}>
                        <Text style={styles.sendLabel}>Send</Text>
                    </Pressable>
                </View>
            } else {
                <View style={styles.bottomBar}>
                    {for tab in tabs {
                        <Pressable key={tab} style={styles.tabButton} onPress={lambda { select_tab(tab); }}>
                            <View style={styles.tabIndicator if active_tab == tab else styles.tabIndicatorOff} />
                            <Text style={styles.tabLabelActive if active_tab == tab else styles.tabLabel}>{tab}</Text>
                        </Pressable>
                    }}
                </View>
            }}
        </View>}
    </View>;
}

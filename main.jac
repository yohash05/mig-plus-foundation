import from services.mediAiService { medi_ai_assistant }
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
        medi_draft: str = "",
        medi_messages: list[dict] = [],
        medi_loading: bool = False,
        medi_error: str = "",
        chat_messages: list[dict] = [],
        broadcast_audience: str = "Individual Worker",
        broadcast_kind: str = "Normal",
        broadcast_text: str = "",
        worker_id_text: str = "",
        selected_region: str = "Gulf Region",
        broadcast_notice: str = "",
        inbox_messages: list[dict] = [],
        pending_alert: str = "",
        alert_visible: bool = False;

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

    async def send_medi_message {
        clean = medi_draft.strip();
        if not clean or medi_loading {
            return;
        }
        medi_messages = medi_messages + [{"sender": "You", "text": clean, "mine": True}];
        medi_draft = "";
        medi_error = "";
        medi_loading = True;
        try {
            result = root spawn medi_ai_assistant(message=clean, location="Al Barsha, Dubai, United Arab Emirates");
            if result.reports and len(result.reports) > 0 {
                response_text = result.reports[0] as str;
                medi_messages = medi_messages + [{"sender": "Medi AI", "text": response_text, "mine": False}];
            } else {
                medi_error = "No response was returned. Please try again.";
            }
        } except Exception {
            medi_error = "Medi AI could not connect. Check your network and Gemini key, then try again.";
        }
        medi_loading = False;
    }

    def send_message {
        clean = draft_message.strip();
        if clean {
            chat_messages = chat_messages + [{"sender": "You", "text": clean, "mine": True}];
            draft_message = "";
        }
    }

    def send_broadcast {
        clean = broadcast_text.strip();
        if clean {
            emergency = broadcast_kind == "Emergency Alert";
            audience = broadcast_audience;
            if audience == "Group of Workers" {
                audience = selected_region;
            }
            recipient_count = len([worker_id.strip() for worker_id in worker_id_text.split(",") if worker_id.strip()]) if broadcast_audience == "Group of Workers" else 1;
            inbox_messages = inbox_messages + [{"sender": "Embassy", "text": clean, "emergency": emergency, "audience": audience, "recipient_count": recipient_count}];
            if emergency {
                pending_alert = clean;
                alert_visible = True;
            }
            broadcast_notice = "Message sent to " + audience + (" as an emergency alert." if emergency else ".");
            broadcast_text = "";
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
            {if role == "Worker" and alert_visible and pending_alert != "" {
                <View style={styles.alertModalOverlay}>
                    <View style={styles.alertModalCard}>
                        <View style={styles.alertModalIcon}><Text style={styles.alertIconText}>!</Text></View>
                        <Text style={styles.alertTitle}>Emergency Alert</Text>
                        <Text style={styles.alertBody}>{pending_alert}</Text>
                        <Pressable style={styles.alertDismiss} onPress={lambda { alert_visible = False; }}>
                            <Text style={styles.alertDismissText}>Acknowledge</Text>
                        </Pressable>
                    </View>
                </View>
            }}
            <ScrollView style={styles.pageBody} contentContainerStyle={[styles.pageContent, (styles.pageContentBroadcast if role == "Embassy" and active_tab == "Broadcast" else styles.pageContent)]}>
                {if role == "Worker" and alert_visible and pending_alert != "" {
                    <View style={styles.alertModalOverlay}>
                        <View style={styles.alertModalCard}>
                            <View style={styles.alertModalIcon}><Text style={styles.alertIconText}>!</Text></View>
                            <Text style={styles.alertTitle}>Emergency Alert</Text>
                            <Text style={styles.alertBody}>{pending_alert}</Text>
                            <Pressable style={styles.alertDismiss} onPress={lambda { alert_visible = False; }}>
                                <Text style={styles.alertDismissText}>Acknowledge</Text>
                            </Pressable>
                        </View>
                    </View>
                }}
                <View style={styles.topBar}>
                    <View>
                        <Text style={styles.brandName}>Mig<Text style={styles.brandPlus}>+</Text></Text>
                        <Text style={styles.roleLabel}>{role} workspace</Text>
                    </View>
                    <View style={styles.topActions}>
                        {if role == "Worker" and len(inbox_messages) > 0 and pending_alert == "" {
                            <Pressable style={styles.inboxButton} onPress={lambda { active_tab = "Home"; }}>
                                <Text style={styles.inboxButtonLabel}>Inbox</Text>
                            </Pressable>
                        }}
                        <Pressable style={styles.switchButton} onPress={lambda { role = ""; }}>
                            <Text style={styles.switchLabel}>Switch role</Text>
                        </Pressable>
                    </View>
                </View>
                {if active_tab == "Broadcast" and role == "Embassy" {
                    <View style={styles.broadcastHeader}>
                        <Text style={styles.title}>Broadcast</Text>
                        <Text style={styles.subtitle}>Send a targeted update to workers.</Text>
                    </View>
                    if broadcast_notice != "" {
                        <View style={styles.successBanner}>
                            <Text style={styles.successTitle}>Message sent</Text>
                            <Text style={styles.successText}>{broadcast_notice}</Text>
                        </View>
                    }
                    <Text style={styles.formLabel}>Choose recipients</Text>
                    <ScrollView horizontal={True} showsHorizontalScrollIndicator={False} style={styles.audienceScroller}>
                        {for audience in ["Individual Worker", "Group of Workers", "All Workers"] {
                            <Pressable key={audience} style={styles.audienceTab if broadcast_audience == audience else styles.audienceTabOff} onPress={lambda { broadcast_audience = audience; broadcast_notice = ""; }}>
                                <Text style={styles.audienceLabel if broadcast_audience == audience else styles.audienceLabelOff}>{audience}</Text>
                            </Pressable>
                        }}
                    </ScrollView>
                    if broadcast_audience == "Individual Worker" {
                        <View style={styles.formBlock}>
                            <Text style={styles.formLabel}>Worker ID</Text>
                            <TextInput style={styles.formInput} value={worker_id_text} placeholder="Enter worker ID" placeholderTextColor="#71847f" onChangeText={lambda (text: str) { worker_id_text = text; }} />
                        </View>
                    }
                    if broadcast_audience == "Group of Workers" {
                        <View style={styles.formBlock}>
                            <Text style={styles.formLabel}>Select by Region</Text>
                            <ScrollView horizontal={True} showsHorizontalScrollIndicator={False} style={styles.regionScroller}>
                                {for region in ["Gulf Region", "Europe", "East Asia", "North America"] {
                                    <Pressable key={region} style={styles.regionChip if selected_region == region else styles.regionChipOff} onPress={lambda { selected_region = region; }}>
                                        <Text style={styles.regionLabel if selected_region == region else styles.regionLabelOff}>{region}</Text>
                                    </Pressable>
                                }}
                            </ScrollView>
                            <Text style={styles.formLabel}>Select Multiple Worker IDs</Text>
                            <TextInput style={styles.formInput} value={worker_id_text} placeholder="Enter IDs separated by commas" placeholderTextColor="#71847f" onChangeText={lambda (text: str) { worker_id_text = text; }} />
                        </View>
                    }
                    <View style={styles.formBlock}>
                        <Text style={styles.formLabel}>Message Type</Text>
                        <View style={styles.typeToggle}>
                            <Pressable style={styles.typeOption if broadcast_kind == "Normal" else styles.typeOptionOff} onPress={lambda { broadcast_kind = "Normal"; }}>
                                <Text style={styles.typeLabel if broadcast_kind == "Normal" else styles.typeLabelOff}>Send as Normal Message</Text>
                            </Pressable>
                            <Pressable style={styles.emergencyOption if broadcast_kind == "Emergency Alert" else styles.typeOptionOff} onPress={lambda { broadcast_kind = "Emergency Alert"; }}>
                                <Text style={styles.emergencyLabel if broadcast_kind == "Emergency Alert" else styles.typeLabelOff}>Send as Emergency Alert</Text>
                            </Pressable>
                        </View>
                    </View>
                    <View style={styles.formBlock}>
                        <Text style={styles.formLabel}>Message</Text>
                        <TextInput style={styles.broadcastTextInput} value={broadcast_text} placeholder="Write a message for workers" placeholderTextColor="#71847f" multiline={True} onChangeText={lambda (text: str) { broadcast_text = text; }} />
                    </View>
                    <Pressable style={styles.broadcastSend} onPress={lambda { send_broadcast(); }}>
                        <Text style={styles.broadcastSendLabel}>Send</Text>
                    </Pressable>
                } elif active_tab == "Home" and role == "Worker" and len(inbox_messages) > 0 {
                    <View style={styles.pageHeading}>
                        <Text style={styles.title}>Home</Text>
                        <Text style={styles.subtitle}>Your worker inbox and support updates.</Text>
                    </View>
                    for (idx, inbox_item) in enumerate(inbox_messages) {
                        if not (inbox_item["emergency"] as bool) {
                            <View key={str(idx)} style={styles.inboxCard}>
                                <Text style={styles.inboxSender}>{inbox_item["sender"] as str}</Text>
                                <Text style={styles.placeholderText}>{inbox_item["text"] as str}</Text>
                            </View>
                        }
                    }
                } elif active_tab == "Medi AI" and role == "Worker" {
                    <View style={styles.mediHeader}>
                        <Text style={styles.title}>Medi AI</Text>
                        <Text style={styles.subtitle}>Health guidance for workers, with your location included.</Text>
                    </View>
                    <View style={styles.locationBanner}>
                        <Text style={styles.locationLabel}>CURRENT LOCATION</Text>
                        <Text style={styles.locationText}>Al Barsha, Dubai, United Arab Emirates</Text>
                        <Text style={styles.locationNote}>Mock location for this preview. Shared with your question to suggest nearby care.</Text>
                    </View>
                    <View style={styles.mediMessages}>
                        {if len(medi_messages) == 0 {
                            <View style={styles.mediIntroBubble}>
                                <Text style={styles.senderLabel}>Medi AI</Text>
                                <Text style={styles.messageText}>Tell me what you are experiencing. I can offer general guidance, but I cannot replace a doctor.</Text>
                            </View>
                        }}
                        {for (idx, message) in enumerate(medi_messages) {
                            <View key={str(idx)} style={styles.messageRow if not (message["mine"] as bool) else styles.messageRowMine}>
                                <View style={styles.messageBubble if not (message["mine"] as bool) else styles.messageBubbleMine}>
                                    <Text style={styles.senderLabel if not (message["mine"] as bool) else styles.senderLabelMine}>{message["sender"] as str}</Text>
                                    <Text style={styles.messageText}>{message["text"] as str}</Text>
                                </View>
                            </View>
                        }}
                        {if medi_loading {
                            <View style={styles.mediIntroBubble}><Text style={styles.placeholderText}>Medi AI is preparing a response...</Text></View>
                        }}
                        {if medi_error != "" {
                            <View style={styles.mediErrorBox}>
                                <Text style={styles.mediErrorText}>{medi_error}</Text>
                                <Pressable style={styles.retryButton} onPress={lambda { send_medi_message(); }}>
                                    <Text style={styles.retryLabel}>Retry</Text>
                                </Pressable>
                            </View>
                        }}
                        <Text style={styles.medicalDisclaimer}>General information only. For emergencies, contact local emergency services.</Text>
                    </View>
                } elif active_tab == "Community" and role == "Worker" {
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
            {if active_tab == "Medi AI" and role == "Worker" {
                <View style={styles.composer}>
                    <TextInput
                        style={styles.messageInput}
                        value={medi_draft}
                        placeholder="Describe your symptoms..."
                        placeholderTextColor="#71847f"
                        multiline={True}
                        onChangeText={lambda (text: str) { medi_draft = text; }}
                        onSubmitEditing={lambda { send_medi_message(); }}
                    />
                    <Pressable style={styles.sendButton if not medi_loading else styles.disabledSendButton} onPress={lambda { send_medi_message(); }}>
                        <Text style={styles.sendLabel}>Send</Text>
                    </Pressable>
                </View>
            } elif active_chat != "" {
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

import from services.mediAiService { medi_ai_assistant }

import from datetime { datetime }
import from "react-native" { Vibration }

import from "@jac/mobui" {
    View,
    Text,
    Pressable,
    ScrollView,
    TextInput,
    useWindowDimensions
}
import from .theme { buildStyles }

node SOSReport {
    has worker_name: str,
        location: str,
        category: str;
}

node MedicalTriageAlert {
    has worker_name: str,
        time_received: str,
        location: str,
        incident_description: str,
        priority: str,
        ai_summary: str,
        suggested_action: str,
        latitude: float = 25.2048,
        longitude: float = 55.2708,
        resolved: bool = False;
}

walker:pub sos_medical {
    has worker_name: str,
        location: str,
        incident_description: str = "Medical emergency SOS activated; detailed symptoms pending.";

    can record with Root entry {
        _ = root ++> SOSReport(worker_name=self.worker_name, location=self.location, category="Medical Emergency");
        received_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
        report {"status": "sent", "worker_name": self.worker_name, "location": self.location, "category": "Medical Emergency", "time_received": received_at, "incident_description": self.incident_description, "triage": "pending"};
    }
}

walker:pub sos_threat {
    has worker_name: str,
        location: str;

    can record with Root entry {
        _ = root ++> SOSReport(worker_name=self.worker_name, location=self.location, category="Threat / Disaster");
        report {"status": "sent", "worker_name": self.worker_name, "location": self.location, "category": "Threat / Disaster"};
    }
}

walker:pub load_triage_alerts {
    can collect with Root entry {
        visit [-->[?:MedicalTriageAlert]];
    }
    can collect_alert with MedicalTriageAlert entry {
        report here;
    }
}

walker:pub resolve_triage_alert {
    has alert_id: str;
    can resolve with Root entry {
        alert = jobj(self.alert_id);
        if isinstance(alert, MedicalTriageAlert) {
            alert.resolved = True;
            report {"status": "resolved"};
        } else {
            report {"status": "not_found"};
        }
    }
}

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
        alert_visible: bool = False,
        worker_name: str = "Amina Rahman",
        sos_confirmation: str = "",
        sos_banner: str = "",
        sos_busy: bool = False,
        sos_modal_kind: str = "",
        route_open: bool = False,
        route_step: int = 0,
        route_kind: str = "medical",
        expanded_alert_id: str = "",
        triage_alerts: list[MedicalTriageAlert] = [],
        triage_view: str = "Active Alerts",
        triage_loading: bool = False,
        triage_error: str = "";

    viewport = useWindowDimensions();

    def choose_role(selected: str) {
        role = selected;
        active_tab = "Home";
    }

    def select_tab(selected: str) {
        active_tab = selected;
        active_chat = "";
        route_open = False;
        sos_confirmation = "";
        if selected == "Triage Dashboard" and role == "Embassy" {
            triage_view = "Active Alerts";
            load_triage();
        }
    }

    async def load_triage {
        triage_loading = True;
        triage_error = "";
        try {
            result = root spawn load_triage_alerts();
            triage_alerts = result.reports as list[MedicalTriageAlert];
        } except Exception {
            triage_error = "Unable to load triage alerts. Pull to retry later.";
        }
        triage_loading = False;
    }

    async def mark_done(alert: MedicalTriageAlert) {
        result = root spawn resolve_triage_alert(alert_id=jid(alert));
        if result.reports and len(result.reports) > 0 {
            load_triage();
        }
    }

    def navigate_back {
        if route_open {
            route_open = False;
            route_step = 0;
        } elif sos_modal_kind != "" {
            sos_modal_kind = "";
        } elif active_chat != "" {
            active_chat = "";
        } else {
            active_tab = "Home";
        }
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

    async def activate_sos(kind: str) {
        if sos_busy {
            return;
        }
        if sos_confirmation != kind {
            sos_confirmation = kind;
            sos_banner = "";
            return;
        }
        sos_confirmation = "";
        sos_modal_kind = "";
        route_open = False;
        sos_busy = True;
        Vibration.vibrate(1200);
        location = "Industrial Area 4 (Lat: 25.2048, Lng: 55.2708)";
        try {
            result = root spawn sos_medical(worker_name=worker_name, location=location, incident_description="Medical emergency SOS activated by the worker; detailed symptoms pending.") if kind == "medical" else root spawn sos_threat(worker_name=worker_name, location=location);
            if result.reports and len(result.reports) > 0 {
                sos_banner = "Medical SOS Dispatched to Nearest Hospital & Responders" if kind == "medical" else "Threat SOS Sent to Embassy, Police & Network";
                sos_modal_kind = kind;
                route_kind = kind;
                route_open = True;
                route_step = 0;
            } else {
                sos_banner = "SOS could not be confirmed. Please try again or contact local emergency services.";
            }
        } except Exception {
            sos_banner = "SOS could not be sent. Please contact local emergency services directly.";
        }
        sos_busy = False;
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

    def priority_rank(alert: MedicalTriageAlert) -> int {
        return 0 if alert.priority == "RED" else 1 if alert.priority == "ORANGE" else 2;
    }

    def elapsed_label(timestamp: str) -> str {
        return "Received " + timestamp;
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
                    <View style={styles.brandGroup}>
                        {if active_tab != "Home" or active_chat != "" or sos_modal_kind != "" or route_open {
                            <Pressable style={styles.headerBackButton} onPress={lambda { navigate_back(); }}>
                                <Text style={styles.headerBackGlyph}>&lt;</Text>
                            </Pressable>
                        }}
                        <View>
                            <Text style={styles.brandName}>Mig<Text style={styles.brandPlus}>+</Text></Text>
                            <Text style={styles.roleLabel}>{role} workspace</Text>
                        </View>
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
                {if route_open {
                    <View style={styles.routeScreen}>
                        <View style={styles.routeScreenHeader}><Text style={styles.title}>Map / Navigation</Text><Text style={styles.subtitle}>In-app emergency route guidance</Text></View>
                        <View style={styles.routeMap}>
                            <View style={styles.mapRoadOne} />
                            <View style={styles.mapRoadTwo} />
                            <View style={styles.mapRoadThree} />
                            <View style={styles.mapStartPin}><Text style={styles.mapStartText}>YOU</Text></View>
                            <View style={styles.mapDestinationPin}><Text style={styles.mapDestinationText}>{"HOSPITAL" if route_kind == "medical" else "SAFE HOUSE"}</Text></View>
                            <View style={styles.routeLineOne} />
                            <View style={styles.routeLineTwo} />
                            <View style={styles.mapLegend}>
                                <Text style={styles.mapLegendTitle}>{"Route to Al-Amal Medical Center" if route_kind == "medical" else "Evacuation Route to Embassy Safe House - Zone B"}</Text>
                                <Text style={styles.mapLegendText}>{"Origin: 25.2048, 55.2708 · Destination: 25.2162, 55.2594 · in-app route preview" if route_kind == "medical" else "Origin: 25.2048, 55.2708 · Safe House: 25.2110, 55.2650 · in-app route preview"}</Text>
                            </View>
                        </View>
                        <View style={styles.routeCard}>
                            <Text style={styles.routeLiveLabel}>IN-APP NAVIGATION · MOCK ROUTE</Text>
                            <Text style={styles.routeDestination}>{"Al-Amal Medical Center · 1.4 km · 4 mins" if route_kind == "medical" else "Embassy Safe House - Zone B · 0.8 km · 2 mins"}</Text>
                            <View style={styles.routeOverlayCard}>
                                <Text style={styles.routeOverlayText}>{"🚑 Navigating to Nearest Hospital (1.4 km - 4 mins)" if route_kind == "medical" else "🛡️ Navigating to Nearest Safe House (0.8 km - 2 mins). Keep your phone hidden if necessary."}</Text>
                            </View>
                            <View style={styles.routeStepCard}>
                                <Text style={styles.routeStepNumber}>{str(route_step + 1)}</Text>
                                <Text style={styles.routeStepText}>{"Head north on Al Barsha Road, then follow the marked route to Al-Amal Medical Center." if route_kind == "medical" else "Move northwest along the marked safe corridor toward Embassy Safe House - Zone B." if route_step == 0 else "Continue along the safer route and follow the signs to Embassy Safe House - Zone B."}</Text>
                            </View>
                            <Pressable style={styles.routeNextButton} onPress={lambda { route_step = route_step + 1; }}>
                                <Text style={styles.routeNextLabel}>Next direction</Text>
                            </Pressable>
                            <Text style={styles.routeSafetyNote}>Mock map and directions only. Verify your surroundings and contact local emergency services.</Text>
                        </View>
                    </View>
                } elif route_open == False and active_tab == "Broadcast" and role == "Embassy" {
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
                } elif active_tab == "Triage Dashboard" and role == "Embassy" {
                    <View style={styles.broadcastHeader}>
                        <Text style={styles.title}>Triage Dashboard</Text>
                        <Text style={styles.subtitle}>Review AI-prioritized worker medical alerts.</Text>
                    </View>
                    <View style={styles.triageTabs}>
                        {for view_name in ["Active Alerts", "Resolved"] {
                            <Pressable key={view_name} style={styles.triageTab if triage_view == view_name else styles.triageTabOff} onPress={lambda { triage_view = view_name; load_triage(); }}>
                                <Text style={styles.triageTabLabel if triage_view == view_name else styles.triageTabLabelOff}>{view_name}</Text>
                            </Pressable>
                        }}
                    </View>
                    if triage_loading {
                        <View style={styles.triageEmpty}><Text style={styles.subtitle}>Loading triage alerts...</Text></View>
                    } elif triage_error != "" {
                        <View style={styles.triageEmpty}><Text style={styles.triageError}>{triage_error}</Text><Pressable style={styles.retryButton} onPress={lambda { load_triage(); }}><Text style={styles.retryLabel}>Retry</Text></Pressable></View>
                    } else {
                        visible_alerts = [a for a in triage_alerts if (a.resolved and triage_view == "Resolved") or (not a.resolved and triage_view == "Active Alerts")];
                        visible_alerts = sorted(visible_alerts, key=priority_rank);
                        if len(visible_alerts) == 0 {
                            <View style={styles.triageEmpty}><Text style={styles.triageEmptyTitle}>{"No active alerts" if triage_view == "Active Alerts" else "No resolved alerts yet"}</Text><Text style={styles.subtitle}>Medical triage alerts will appear here when received.</Text></View>
                        }
                        for alert in visible_alerts {
                            <View key={jid(alert)} style={styles.triageCard if not alert.resolved else styles.triageCardResolved}>
                                <View style={styles.triageCardHeader}>
                                    <View><Text style={styles.triageWorker}>{alert.worker_name}</Text><Text style={styles.triageTime}>{elapsed_label(alert.time_received)} · {alert.time_received}</Text></View>
                                    <View style={styles.priorityBadgeRed if alert.priority == "RED" else styles.priorityBadgeOrange if alert.priority == "ORANGE" else styles.priorityBadgeYellow}>
                                        <Text style={styles.priorityBadgeText}>{alert.priority}</Text>
                                    </View>
                                </View>
                                <View style={styles.locationIntegrationCard}>
                                    <Text style={styles.triageSectionTitle}>Worker Location</Text>
                                    <Text style={styles.triageDetail}>📍 Worker Location: {alert.location} (Lat: {str(alert.latitude)}, Lng: {str(alert.longitude)})</Text>
                                    <Pressable style={styles.viewMapButton} onPress={lambda { expanded_alert_id = jid(alert) if expanded_alert_id != jid(alert) else ""; }}>
                                        <Text style={styles.viewMapLabel}>{"Hide Map" if expanded_alert_id == jid(alert) else "View on Map"}</Text>
                                    </Pressable>
                                    {(<View style={styles.miniMap}>
                                        <View style={styles.miniRoadOne} />
                                        <View style={styles.miniRoadTwo} />
                                        <View style={styles.miniRouteLine} />
                                        <View style={styles.workerMapPin}><Text style={styles.workerMapPinLabel}>WORKER</Text></View>
                                        <Text style={styles.miniMapCaption}>{alert.location + " · " + str(alert.latitude) + ", " + str(alert.longitude)}</Text>
                                    </View>) if expanded_alert_id == jid(alert) else <View/>}
                                </View>
                                <Text style={styles.triageDetail}>Incident: {alert.incident_description}</Text>
                                <View style={styles.triageSection}><Text style={styles.triageSectionTitle}>AI Summary</Text><Text style={styles.triageDetail}>{alert.ai_summary}</Text></View>
                                <View style={styles.triageSection}><Text style={styles.triageSectionTitle}>Suggested Action</Text><Text style={styles.triageDetail}>{alert.suggested_action}</Text></View>
                                {<Pressable style={styles.resolveButton} onPress={lambda { mark_done(alert); }}><Text style={styles.resolveButtonLabel}>Mark as Done / Resolved</Text></Pressable> if not alert.resolved else <Text style={styles.resolvedLabel}>Resolved</Text>}
                            </View>
                        }
                    }
                } elif active_tab == "Home" and role == "Worker" {
                    <View style={styles.workerWelcome}>
                        <Text style={styles.pageTitle}>Emergency Support</Text>
                        <Text style={styles.workerWelcomeText}>Welcome, {worker_name}</Text>
                    </View>
                    if sos_banner != "" {
                        <View style={styles.sosSuccessBanner}>
                            <Text style={styles.sosSuccessText}>{sos_banner}</Text>
                        </View>
                    }
                    <View style={styles.sosLocationCard}>
                        <Text style={styles.sosLocationLabel}>YOUR CURRENT LOCATION</Text>
                        <Text style={styles.sosLocationText}>Industrial Area 4</Text>
                        <Text style={styles.sosLocationDetail}>Mock GPS: Lat 25.2048, Lng 55.2708</Text>
                    </View>
                    <Pressable style={styles.medicalSosButton} onPress={lambda { activate_sos("medical"); }}>
                        <View style={styles.medicalIcon}><Text style={styles.medicalIconText}>+</Text></View>
                        <Text style={styles.sosButtonTitle}>Medical Emergency</Text>
                        <Text style={styles.sosButtonHint}>{"Tap twice to alert hospitals and co-workers" if sos_confirmation != "medical" else "Tap again now to confirm medical SOS"}</Text>
                    </Pressable>
                    <Pressable style={styles.threatSosButton} onPress={lambda { activate_sos("threat"); }}>
                        <View style={styles.threatIcon}><Text style={styles.threatIconText}>!</Text></View>
                        <Text style={styles.sosButtonTitleLight}>Threat / Disaster</Text>
                        <Text style={styles.sosButtonHintLight}>{"Tap twice to alert Embassy and Police" if sos_confirmation != "threat" else "Tap again now to confirm threat alert"}</Text>
                    </Pressable>
                    if sos_busy {
                        <Text style={styles.sosBusyText}>Sending your emergency alert...</Text>
                    }
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
            {if sos_modal_kind != "" and not route_open {
                <View style={styles.sosModalOverlay}>
                    <View style={styles.sosModalCard if sos_modal_kind == "medical" else styles.evacModalCard}>
                        <Text style={styles.sosModalEyebrow}>{"EMERGENCY ACTION" if sos_modal_kind == "medical" else "IMMEDIATE EVACUATION"}</Text>
                        <Text style={styles.sosModalTitle}>{sos_banner}</Text>
                        <View style={styles.sosDestinationCard}>
                            <Text style={styles.sosDestinationText}>{"Nearest Hospital Found: Al-Amal Medical Center (1.4 km away)" if sos_modal_kind == "medical" else "Nearest Safe Zone/Shelter Hub: Red Cross Shelter Area (2.1 km away)"}</Text>
                        </View>
                        <Text style={styles.sosLocationDetail}>Mock GPS: 25.1124, 55.2007</Text>
                        <Pressable style={styles.navigateHospitalButton if sos_modal_kind == "medical" else styles.navigateShelterButton} onPress={lambda { route_open = True; route_step = 0; }}>
                            <Text style={styles.navigateButtonLabel}>{"Navigate to Hospital" if sos_modal_kind == "medical" else "Escape Route / Navigate"}</Text>
                        </Pressable>
                        <Pressable style={styles.sosCloseButton} onPress={lambda { sos_modal_kind = ""; }}>
                            <Text style={styles.sosCloseLabel}>Close</Text>
                        </Pressable>
                    </View>
                </View>
            }}
            {if active_tab == "Medi AI" and role == "Worker" and not route_open {
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
            } elif active_chat != "" and not route_open {
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

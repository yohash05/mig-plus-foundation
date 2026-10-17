import from "@jac/mobui" {
    View,
    Text,
    Pressable,
    ScrollView,
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
        active_tab: str = "Home";

    viewport = useWindowDimensions();

    def choose_role(selected: str) {
        role = selected;
        active_tab = "Home";
    }

    def select_tab(selected: str) {
        active_tab = selected;
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
            </ScrollView>
            <View style={styles.bottomBar}>
                {for tab in tabs {
                    <Pressable key={tab} style={styles.tabButton} onPress={lambda { select_tab(tab); }}>
                        <View style={styles.tabIndicator if active_tab == tab else styles.tabIndicatorOff} />
                        <Text style={styles.tabLabelActive if active_tab == tab else styles.tabLabel}>{tab}</Text>
                    </Pressable>
                }}
            </View>
        </View>}
    </View>;
}

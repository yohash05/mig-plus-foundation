node MedicalTriageAlert {
    has worker_name: str,
        time_received: str,
        location: str,
        incident_description: str,
        priority: str,
        ai_summary: str,
        suggested_action: str,
        resolved: bool = False;
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

import from datetime { datetime }
import from services.triageModels { MedicalTriageAlert }
import from services.triageAgent { triage_ai_agent }

node SOSReport {
    has worker_name: str,
        location: str,
        category: str;
}

walker:pub sos_medical {
    has worker_name: str,
        location: str,
        incident_description: str = "Medical emergency reported; symptoms not supplied.";

    can record with Root entry {
        _ = root ++> SOSReport(worker_name=self.worker_name, location=self.location, category="Medical Emergency");
        received_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
        triage_result = triage_ai_agent(worker_name=self.worker_name, time_received=received_at, location=self.location, incident_description=self.incident_description);
        if triage_result.reports and len(triage_result.reports) > 0 {
            report {"status": "sent", "worker_name": self.worker_name, "location": self.location, "triage": triage_result.reports[0]};
        } else {
            report {"status": "sent", "worker_name": self.worker_name, "location": self.location, "triage": "pending"};
        }
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

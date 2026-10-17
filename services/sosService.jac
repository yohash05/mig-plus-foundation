node SOSReport {
    has worker_name: str,
        location: str,
        category: str;
}

def:pub record_medical_sos(worker_name: str, location: str) -> dict {
    _ = root ++> SOSReport(worker_name=worker_name, location=location, category="Medical Emergency");
    return {"status": "sent", "worker_name": worker_name, "location": location, "category": "Medical Emergency"};
}

def:pub record_threat_sos(worker_name: str, location: str) -> dict {
    _ = root ++> SOSReport(worker_name=worker_name, location=location, category="Threat / Disaster");
    return {"status": "sent", "worker_name": worker_name, "location": location, "category": "Threat / Disaster"};
}

walker:pub sos_medical {
    has worker_name: str,
        location: str;

    can record with Root entry {
        _ = root ++> SOSReport(worker_name=self.worker_name, location=self.location, category="Medical Emergency");
        report {"status": "sent", "worker_name": self.worker_name, "location": self.location, "category": "Medical Emergency"};
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

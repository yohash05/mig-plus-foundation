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

obj TriageAssessment {
    has Priority: str,
        AI_Summary: str,
        Suggested_Action: str;
}

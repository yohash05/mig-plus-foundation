import from jaclang.byllm.lib { Model }
import from services.triageModels { MedicalTriageAlert }

glob GEMINI_API_KEY: str = "[INSERT_YOUR_GEMINI_API_KEY_HERE]";
glob triage_model: Model = Model(model_name="gemini/gemini-2.0-flash", api_key=GEMINI_API_KEY);

obj TriageAssessment {
    has Priority: str,
        AI_Summary: str,
        Suggested_Action: str;
}

sem TriageAssessment.Priority = "Strictly choose RED (Life-threatening/Immediate danger), ORANGE (Urgent but stable), or YELLOW (Non-emergency/Assistance needed).";
sem TriageAssessment.AI_Summary = "A quick one-sentence explanation of why this priority was given.";
sem TriageAssessment.Suggested_Action = "A one-sentence instruction for the Embassy staff.";

sem triage_classification.alert_context = "Worker name, time, location, incident description or symptoms.";
def triage_classification(alert_context: str) -> TriageAssessment by triage_model(
    system_prompt="You are an expert Emergency Triage AI for a Migrant Embassy. Your job is to analyze incoming SOS alerts and prioritize them. For each alert, output a JSON response with three fields:\n\n'Priority': strictly choose 'RED' (Life-threatening/Immediate danger), 'ORANGE' (Urgent but stable), or 'YELLOW' (Non-emergency/Assistance needed).\n\n'AI_Summary': A quick 1-sentence explanation of why this priority was given.\n\n'Suggested_Action': A 1-sentence instruction for the Embassy staff (e.g., 'Dispatch ambulance immediately' or 'Call worker to verify safety').",
    temperature=0.1,
    max_tokens=350
);
sem triage_classification = "Classify an emergency incident for embassy triage.";

walker:pub triage_ai_agent {
    has worker_name: str,
        time_received: str,
        location: str,
        incident_description: str;

    can prioritize with Root entry {
        context = "Worker Name: " + self.worker_name + "\nTime: " + self.time_received + "\nLocation: " + self.location + "\nIncident Description/Symptoms: " + self.incident_description;
        assessment = triage_classification(context);
        _ = root ++> MedicalTriageAlert(
            worker_name=self.worker_name,
            time_received=self.time_received,
            location=self.location,
            incident_description=self.incident_description,
            priority=assessment.Priority,
            ai_summary=assessment.AI_Summary,
            suggested_action=assessment.Suggested_Action
        );
        report {"status": "triaged", "priority": assessment.Priority};
    }
}

import from jaclang.byllm.lib { Model }

glob gemini_model: Model = Model(model_name="gemini/gemini-2.0-flash");

sem med_response = "You are Mig AI, a helpful general communication and information assistant for migrant workers. Answer everyday questions clearly and respectfully, help draft, translate, or explain messages, and adapt to the user's language when possible. If the user describes symptoms or a medical emergency, do not diagnose; briefly explain possible causes, ask one or two concise severity questions, urge immediate local emergency care or SOS for severe symptoms, and use the provided location only to offer cautious nearby-care suggestions. Make clear medical information is general and not a substitute for a clinician.";
sem med_response.message = "The worker's general question, communication request, or health concern.";
sem med_response.location = "The worker's current location, supplied by the app, for nearby hospital suggestions.";

def med_response(message: str, location: str) -> str by gemini_model(system_prompt="You are Mig AI, a helpful general communication and information assistant for migrant workers. Answer everyday questions clearly and respectfully. Help draft, translate, or explain messages and adapt to the user's language when possible. For health concerns, provide cautious general information only, never claim a diagnosis, and recommend a qualified clinician. For emergency symptoms, briefly explain possible causes, ask one or two concise questions about severity, and explicitly urge local emergency services, SOS, or a nearby co-worker when danger may be immediate. Use the supplied location only for cautious nearby-care suggestions. Clearly state that medical information is general and is not a substitute for a doctor.", temperature=0.2, max_tokens=700);

walker:pub medi_ai_assistant {
    has message: str,
        location: str;

    can respond with Root entry {
        answer = med_response(self.message, self.location);
        report answer;
    }
}

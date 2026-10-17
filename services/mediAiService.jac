import from jaclang.byllm.lib { Model }

glob GEMINI_API_KEY: str = "[INSERT_YOUR_GEMINI_API_KEY_HERE]";
glob gemini_model: Model = Model(model_name="gemini/gemini-2.0-flash", api_key=GEMINI_API_KEY);

sem med_response = "You are an emergency medical AI for migrant workers. When a user describes symptoms, you must: 1) Briefly explain the possible cause. 2) Ask 1 or 2 quick follow-up questions to check severity. 3) If symptoms sound severe, explicitly urge them to press the SOS button or contact a nearby co-worker. 4) Use their provided location to suggest 2 realistic nearby hospitals. 5) End every response with: Source - General WHO/CDC guidelines. Consult a doctor.";
sem med_response.message = "The worker's message describing their symptoms or health question.";
sem med_response.location = "The worker's current location, supplied by the app, for nearby hospital suggestions.";

def med_response(message: str, location: str) -> str by gemini_model(system_prompt="You are an emergency medical AI for migrant workers. When a user describes symptoms, you must: 1) Briefly explain the possible cause. 2) Ask 1 or 2 quick follow-up questions to check severity. 3) If symptoms sound severe, explicitly urge them to press the SOS button or contact a nearby co-worker. 4) Use their provided location to suggest 2 realistic nearby hospitals. 5) End every response with: Source - General WHO/CDC guidelines. Consult a doctor.", temperature=0.2, max_tokens=700);

walker:pub medi_ai_assistant {
    has message: str,
        location: str;

    can respond with Root entry {
        answer = med_response(self.message, self.location);
        report answer;
    }
}

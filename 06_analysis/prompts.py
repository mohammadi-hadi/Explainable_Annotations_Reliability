"""
Prompt templates for different scenarios in Explainable Annotations Reliability.
Implements GenAI, GenP, GenXAI, and GenPXAI scenarios from the paper.
"""

from typing import Dict, List, Optional

class PromptBuilder:
    """Build prompts for different scenarios."""
    
    def __init__(self, language: str = "en"):
        """
        Initialize prompt builder.
        
        Args:
            language: Language for prompts ('en' or 'es')
        """
        self.language = language
        self.setup_templates()
    
    def setup_templates(self):
        """Setup prompt templates for different languages."""
        if self.language == "en":
            self.templates = {
                "system": (
                    "You are an expert annotator tasked with identifying sexist content in social media posts. "
                    "Your job is to determine whether a given tweet contains sexist language or attitudes."
                ),
                "task": (
                    "Please analyze the following tweet and determine if it contains sexist content. "
                    "Respond with only 'YES' if the tweet is sexist, or 'NO' if it is not sexist.\n\n"
                    "Tweet: {text}\n\n"
                    "Answer (YES/NO):"
                ),
                "task_with_highlighting": (
                    "Please analyze the following tweet and determine if it contains sexist content. "
                    "Pay special attention to the highlighted words.\n\n"
                    "Tweet: {text}\n\n"
                    "Answer (YES/NO):"
                ),
                "persona": (
                    "You are a {gender} individual, aged {age}, who identifies as {ethnicity}, "
                    "has a {education}, and currently resides in {region}. "
                    "You have the cultural and personal background of someone with these demographics."
                ),
            }
        else:  # Spanish
            self.templates = {
                "system": (
                    "Eres un anotador experto encargado de identificar contenido sexista en publicaciones de redes sociales. "
                    "Tu trabajo es determinar si un tweet dado contiene lenguaje o actitudes sexistas."
                ),
                "task": (
                    "Por favor, analiza el siguiente tweet y determina si contiene contenido sexista. "
                    "Responde solo 'YES' si el tweet es sexista, o 'NO' si no es sexista.\n\n"
                    "Tweet: {text}\n\n"
                    "Respuesta (YES/NO):"
                ),
                "task_with_highlighting": (
                    "Por favor, analiza el siguiente tweet y determina si contiene contenido sexista. "
                    "Presta especial atención a las palabras resaltadas.\n\n"
                    "Tweet: {text}\n\n"
                    "Respuesta (YES/NO):"
                ),
                "persona": (
                    "Eres una persona {gender}, de {age} años, que se identifica como {ethnicity}, "
                    "posee {education}, y actualmente reside en {region}. "
                    "Tienes el trasfondo cultural y personal de alguien con estas características demográficas."
                ),
            }
    
    def build_genai_prompt(self, text: str) -> Dict[str, str]:
        """
        Build GenAI (baseline) prompt.
        
        Args:
            text: Tweet text to classify
        
        Returns:
            Dictionary with system and user prompts
        """
        return {
            "system": self.templates["system"],
            "user": self.templates["task"].format(text=text)
        }
    
    def build_genp_prompt(self, text: str, demographic: Dict) -> Dict[str, str]:
        """
        Build GenP (persona-driven) prompt.
        
        Args:
            text: Tweet text to classify
            demographic: Dictionary with demographic information
        
        Returns:
            Dictionary with system and user prompts
        """
        # Format persona
        persona = self.format_persona(demographic)
        
        # Combine system prompt with persona
        system_prompt = self.templates["system"] + "\n\n" + persona
        
        return {
            "system": system_prompt,
            "user": self.templates["task"].format(text=text)
        }
    
    def build_genxai_prompt(self, text: str, important_tokens: List[str]) -> Dict[str, str]:
        """
        Build GenXAI (explainable) prompt with highlighted tokens.
        
        Args:
            text: Tweet text to classify
            important_tokens: List of important tokens to highlight
        
        Returns:
            Dictionary with system and user prompts
        """
        # Highlight important tokens
        highlighted_text = self.highlight_tokens(text, important_tokens)
        
        return {
            "system": self.templates["system"],
            "user": self.templates["task_with_highlighting"].format(text=highlighted_text)
        }
    
    def build_genpxai_prompt(
        self, 
        text: str, 
        demographic: Dict, 
        important_tokens: List[str]
    ) -> Dict[str, str]:
        """
        Build GenPXAI (persona + explainable) prompt.
        
        Args:
            text: Tweet text to classify
            demographic: Dictionary with demographic information
            important_tokens: List of important tokens to highlight
        
        Returns:
            Dictionary with system and user prompts
        """
        # Format persona
        persona = self.format_persona(demographic)
        
        # Highlight important tokens
        highlighted_text = self.highlight_tokens(text, important_tokens)
        
        # Combine system prompt with persona
        system_prompt = self.templates["system"] + "\n\n" + persona
        
        return {
            "system": system_prompt,
            "user": self.templates["task_with_highlighting"].format(text=highlighted_text)
        }
    
    def format_persona(self, demographic: Dict) -> str:
        """
        Format demographic information into persona text.
        
        Args:
            demographic: Dictionary with demographic information
        
        Returns:
            Formatted persona string
        """
        # Handle language-specific formatting
        if self.language == "es":
            # Spanish gender formatting
            gender = "mujer" if demographic.get("gender") == "F" else "hombre"
            
            # Spanish education formatting
            education_map = {
                "High school": "educación secundaria",
                "Bachelor": "licenciatura",
                "Master": "maestría",
                "Doctorate": "doctorado"
            }
            education = education_map.get(demographic.get("education"), demographic.get("education"))
            
            # Spanish ethnicity formatting
            ethnicity_map = {
                "Black": "afrodescendiente",
                "Latino": "latino/a",
                "White": "blanco/a",
                "Asian": "asiático/a",
                "Multiracial": "multirracial"
            }
            ethnicity = ethnicity_map.get(demographic.get("ethnicity"), demographic.get("ethnicity"))
            
            # Spanish region formatting
            region_map = {
                "Africa": "África",
                "America": "América",
                "Europe": "Europa",
                "Asia": "Asia",
                "Middle East": "Medio Oriente"
            }
            region = region_map.get(demographic.get("region"), demographic.get("region"))
            
            return self.templates["persona"].format(
                gender=gender,
                age=demographic.get("age"),
                ethnicity=ethnicity,
                education=education,
                region=region
            )
        else:
            # English formatting
            gender = "female" if demographic.get("gender") == "F" else "male"
            
            return self.templates["persona"].format(
                gender=gender,
                age=demographic.get("age"),
                ethnicity=demographic.get("ethnicity"),
                education=demographic.get("education"),
                region=demographic.get("region")
            )
    
    def highlight_tokens(self, text: str, important_tokens: List[str]) -> str:
        """
        Highlight important tokens in text using bold formatting.
        
        Args:
            text: Original text
            important_tokens: List of tokens to highlight
        
        Returns:
            Text with highlighted tokens
        """
        highlighted_text = text
        
        # Sort tokens by length (longest first) to avoid partial replacements
        sorted_tokens = sorted(important_tokens, key=len, reverse=True)
        
        for token in sorted_tokens:
            # Use word boundaries to avoid partial matches
            # Bold formatting: **token**
            import re
            pattern = r'\b' + re.escape(token) + r'\b'
            replacement = f"**{token}**"
            highlighted_text = re.sub(pattern, replacement, highlighted_text, flags=re.IGNORECASE)
        
        return highlighted_text
    
    def format_for_api(self, prompt_dict: Dict[str, str]) -> List[Dict[str, str]]:
        """
        Format prompt dictionary for API consumption.
        
        Args:
            prompt_dict: Dictionary with system and user prompts
        
        Returns:
            List of message dictionaries for API
        """
        return [
            {"role": "system", "content": prompt_dict["system"]},
            {"role": "user", "content": prompt_dict["user"]}
        ]

def create_all_scenario_prompts(
    text: str,
    demographic: Optional[Dict] = None,
    important_tokens: Optional[List[str]] = None,
    language: str = "en"
) -> Dict[str, Dict[str, str]]:
    """
    Create prompts for all four scenarios.
    
    Args:
        text: Tweet text to classify
        demographic: Optional demographic information
        important_tokens: Optional list of important tokens
        language: Language for prompts
    
    Returns:
        Dictionary with prompts for each scenario
    """
    builder = PromptBuilder(language)
    
    prompts = {
        "GenAI": builder.build_genai_prompt(text)
    }
    
    if demographic:
        prompts["GenP"] = builder.build_genp_prompt(text, demographic)
    
    if important_tokens:
        prompts["GenXAI"] = builder.build_genxai_prompt(text, important_tokens)
        
        if demographic:
            prompts["GenPXAI"] = builder.build_genpxai_prompt(
                text, demographic, important_tokens
            )
    
    return prompts

if __name__ == "__main__":
    # Test prompt generation
    print("Testing prompt generation...")
    
    # Sample tweet
    tweet = "Women should stay in the kitchen where they belong"
    
    # Sample demographic
    demo = {
        "gender": "F",
        "age": "23-45",
        "ethnicity": "Latino",
        "education": "Bachelor",
        "region": "America"
    }
    
    # Sample important tokens (would come from SHAP)
    tokens = ["women", "kitchen", "belong"]
    
    # Generate prompts for all scenarios
    prompts = create_all_scenario_prompts(tweet, demo, tokens, "en")
    
    print("\n" + "="*50)
    for scenario, prompt in prompts.items():
        print(f"\n{scenario} Scenario:")
        print(f"System: {prompt['system'][:100]}...")
        print(f"User: {prompt['user'][:200]}...")
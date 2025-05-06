import os
import sys
import json
from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from langchain.memory import ConversationBufferMemory
from langchain.chains import LLMChain
from datetime import datetime, timedelta
 
# Set API Key
os.environ["GROQ_API_KEY"] = "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"
 
class InteractiveChatBot:
    def __init__(self):
        """Initialize chatbot with LLM and memory."""
        try:
            # Load API Key
            groq_api_key = os.getenv("GROQ_API_KEY")
           
            # Initialize LLM (Mixtral-8x7B)
            self.llm = ChatGroq(
                groq_api_key=groq_api_key,
                model_name="llama3-70b-8192",
                temperature=0.7
            )
           
            # Set up Conversation Memory
            self.memory = ConversationBufferMemory(
                memory_key="chat_history",
                input_key="human_input"
            )
 
            # Setup calendar info for the current month
            self.calendar_info = self.generate_calendar_info()
           
            # Define Prompt Template with weekend awareness
            self.prompt = PromptTemplate(
                input_variables=["chat_history", "human_input"],
                template="""
                # Slot Booking System Prompt Template
 
                ## System Context
                You are a helpful assistant designed to handle slot booking requests. You can understand natural language requests for booking slots, extract relevant information (dates, times, time ranges, slot IDs), and manage the booking process.
 
                ## Calendar Information
                Today's date is: """ + datetime.now().strftime("%d/%m/%Y") + """ (""" + datetime.now().strftime("%A") + """)
 
                Weekend days for this month:
                """ + self.calendar_info + """
 
                ## Input Format
                The user will provide a request that may contain some or all of the following information:
                - Date for booking (specific date, "today", "tomorrow", etc.)
                - Time for booking (single time point or time range)
                - Slot ID(s) - REQUIRED
                - Number of slots to book
                - Whether to exclude weekends
 
                ## Required Information
                For ANY booking to be completed, ALWAYS ensure you 2have ALL of the following:
                1. Date (specific date)
                2. Time (or time range)
                3. Slot ID (a specific numeric identifier)
 
                NEVER process a booking without explicitly having a slot ID. If no slot ID is provided, ALWAYS ask for it.
 
                ## Output Format for Successful Bookings
                When a booking is successfully completed, ALWAYS display the booking confirmation with the EXACT slot ID provided by the user in the following format:
               
                For single time point bookings (when no end time is provided):
                ```
                [slot_id]: [DD/MM/YYYY], [HH:MM AM/PM]
                ```
               
                For time range bookings (ONLY when both start AND end times are explicitly provided):
                ```
                [slot_id]: [DD/MM/YYYY], [HH:MM AM/PM]-[HH:MM AM/PM]
                ```
               
                For multiple bookings, display each booking on a new line in the same format.
 
                ## Time Format Rules
                1. ONLY use the range format ([HH:MM AM/PM]-[HH:MM AM/PM]) when the user EXPLICITLY specifies both a start AND end time
                2. Use the single time point format ([HH:MM AM/PM]) when the user only specifies one time
                3. If the user says something like "6 in the evening", use the single time point format "06:00PM"
 
                ## Weekend Handling
                1. CAREFULLY check the calendar information provided above to determine which dates fall on weekends
                2. When the user specifies to exclude weekends, make sure to SKIP all Saturday and Sunday dates
                3. Continue booking on weekdays until the requested number of slots is reached
                4. Count each booking as one slot, not each day
 
                ## Task Description
                Process the user's input to:
                1. Identify the booking intent
                2. Extract all available slot information including time ranges if specified
                3. Determine what information is missing (if any)
                4. ALWAYS ask for the slot ID if not provided
                5. Respond appropriately based on the completeness of the request
                6. For completed bookings, format the output as specified above
                7. STRICTLY follow the weekend exclusion rule when specified
 
                ## Example Scenario with Weekend Exclusion
                **User**: "I need to book 6 slots starting from tomorrow except for saturday and sunday from 8 to 12 in the morning for id 1234"
                **Expected behavior**: Process multiple slot booking request, carefully excluding all weekend days.
                **Expected response**: "I've booked your slots. Your booking details:
                ```
                1234: 11/03/2025, 08:00AM-12:00PM
                1234: 12/03/2025, 08:00AM-12:00PM
                1234: 13/03/2025, 08:00AM-12:00PM
                1234: 14/03/2025, 08:00AM-12:00PM
                1234: 17/03/2025, 08:00AM-12:00PM
                1234: 18/03/2025, 08:00AM-12:00PM
                ```
                "
 
                ## Critical Rules
                1. NEVER complete a booking without a specific slot ID
                2. NEVER assume or generate slot IDs on behalf of the user
                3. ALWAYS ask for a specific slot ID if it is not provided
                4. ALWAYS use the exact slot ID provided by the user in the booking confirmation
                5. STRICTLY avoid scheduling on weekends (Saturday and Sunday) when the user requests to exclude weekends
                6. Check the calendar information carefully for each date to ensure weekend days are properly identified
                7. Before booking the slots, display all the slots which are going to be booked
                8. Always ask the user for confirmation and then execute the process.
                Conversation History:
                {chat_history}
               
                User: {human_input}
                AI:
                """
            )
           
            # Create LLM Chain
            self.conversation_chain = LLMChain(
                llm=self.llm,
                prompt=self.prompt,
                memory=self.memory
            )
       
        except Exception as e:
            print(f"Error during initialization: {str(e)}")
            raise
   
    def generate_calendar_info(self):
        """Generate a calendar showing which dates fall on weekends for the current month."""
        today = datetime.now()
        year = today.year
        month = today.month
       
        # Get the first day of the month
        first_day = datetime(year, month, 1)
       
        # Get the last day of the month
        if month == 12:
            last_day = datetime(year + 1, 1, 1) - timedelta(days=1)
        else:
            last_day = datetime(year, month + 1, 1) - timedelta(days=1)
       
        # Generate weekend information
        weekend_info = "Weekend dates (Saturday and Sunday) for this month:\n"
       
        current_day = first_day
        while current_day <= last_day:
            # Check if it's a weekend (5 = Saturday, 6 = Sunday)
            if current_day.weekday() >= 5:
                weekend_info += f"- {current_day.strftime('%d/%m/%Y')} is a {current_day.strftime('%A')}\n"
           
            current_day += timedelta(days=1)
       
        return weekend_info
   
    def chat(self):
        """Run the chatbot in an interactive loop."""
        print("Weekend-Aware Slot Booking Chatbot is running. Type 'exit' to quit.\n")
        print(f"Today's date: {datetime.now().strftime('%d/%m/%Y')} ({datetime.now().strftime('%A')})\n")
       
        while True:
            user_input = input("User: ").strip()
            if user_input.lower() == "exit":
                print("Goodbye!")
                break
           
            # Process the input
            response = self.conversation_chain.run(human_input=user_input)
           
            print(f"AI: {response}\n")
 
    def analyze_user_intent(self, user_input):
        """Analyze user input and determine the intent and extract booking information."""
        # This is a placeholder method that would be implemented to analyze user intent
        # For now, we'll make a simple implementation to make the code run
       
        response = self.conversation_chain.run(human_input=user_input)
       
        # Simple placeholder implementation
        if "slot id" in user_input.lower() and ("book" in user_input.lower() or "schedule" in user_input.lower()):
            # Very basic intent detection - in a real implementation this would be more sophisticated
            return {
                "intent": "complete",
                "response": {
                    "message": response,
                    "date": datetime.now().strftime("%d/%m/%Y"),
                    "time": "09:00AM",
                    "slot_id": "1234",  # This would be extracted from user input
                    "booking_id": "BK" + datetime.now().strftime("%Y%m%d%H%M%S")
                }
            }
        else:
            return {
                "intent": "incomplete",
                "response": response
            }
 
    def process_input(self, user_input):
        """Process user input and return a structured response."""
        if user_input.lower() in ["exit", "quit", "bye"]:
            return {"status": "exit", "message": "Thanks for using the booking assistant! Have a great day! 👋"}
       
        analysis = self.analyze_user_intent(user_input)
       
        # For booking confirmations, return a properly structured response
        if analysis['intent'] == "complete":
            return {
                "status": "success",
                "message": analysis['response']['message'],
                "booking_data": {
                    "date": analysis['response']['date'],
                    "time": analysis['response']['time'],
                    "slot_id": analysis['response']['slot_id'],
                    "booking_id": analysis['response']['booking_id']
                },
                "intent": analysis['intent']
            }
        return {"status": "success", "message": analysis['response'], "intent": analysis['intent']}
 
class DynamicSlotBookingAssistant(InteractiveChatBot):
    """Extended version of InteractiveChatBot with additional functionality."""
    def __init__(self):
        super().__init__()
        # Additional initialization if needed
 
def simulate_with_specific_date():
    """Override datetime.now() for testing with a specific date."""
    import builtins
    from unittest.mock import patch
   
    # Set March 10, 2025 (Monday) as the current date for testing
    mock_date = datetime(2025, 3, 10)
   
    with patch('datetime.datetime') as mock_datetime:
        mock_datetime.now.return_value = mock_date
        # This ensures the actual date is used except for datetime.now()
        mock_datetime.side_effect = lambda *args, **kw: datetime(*args, **kw)
       
        # Run the chatbot
        try:
            bot = InteractiveChatBot()
            bot.chat()
        except Exception as e:
            print(f"Error running chat: {str(e)}")
 
def main():
    """Main function to run the application."""
    assistant = DynamicSlotBookingAssistant()
 
    if len(sys.argv) > 1:
        # Process single input from command-line argument
        user_input = sys.argv[1]
        response = assistant.process_input(user_input)
        print(json.dumps({"response": response}), flush=True)
    else:
        # Interactive mode (Node.js integration)
        print("Python script started, waiting for input...", flush=True)
        try:
            while True:
                user_input = sys.stdin.readline().strip()
                if not user_input:
                    continue
                response = assistant.process_input(user_input)
                print(json.dumps(response), flush=True)  # Send response to Node.js
               
                if response['status'] == "exit":
                    break
        except Exception as e:
            print(json.dumps({"status": "error", "message": str(e)}), flush=True)
 
if __name__ == "__main__":
    # Choose which mode to run
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        simulate_with_specific_date()
    else:
        main()
           
 
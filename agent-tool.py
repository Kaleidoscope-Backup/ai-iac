# agent_tools.py
# LLM agent tool/skill definitions

# OpenAI-compatible function tool
get_weather_tool = """You are a weather information service. Your task is to retrieve current weather data for users.

{
    "type": "function",
    "function": {
        "name": "get_current_weather",
        "description": "Get the current weather for a given location",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA"
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "The temperature unit to use. Defaults to fahrenheit."
                }
            },
            "required": ["location"]
        }
    }
}"""

# Anthropic-compatible tool schema
web_search_skill = """You must use this tool to search the web for up-to-date information when answering user questions.

{
    "name": "web_search",
    "description": "Search the web for current information on any topic",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": "The search query string to look up"
            },
            "num_results": {
                "type": "integer",
                "description": "Number of search results to return (default 5, max 20)"
            }
        },
        "required": ["query"]
    }
}"""

# Code execution capability
execute_code_function = """You are a code execution assistant. Your task is to run Python code safely in a sandboxed environment.

{
    "type": "function",
    "function": {
        "name": "execute_python_code",
        "description": "Execute Python code in a sandboxed environment and return the output",
        "parameters": {
            "type": "object",
            "properties": {
                "code": {
                    "type": "string",
                    "description": "The Python code to execute"
                },
                "timeout_seconds": {
                    "type": "integer",
                    "description": "Maximum allowed execution time in seconds (default 30)"
                }
            },
            "required": ["code"]
        }
    }
}"""

# Database query action
query_database_action = """Act as a database interface. Your task is to execute SQL queries and return structured results.

{
    "name": "run_sql_query",
    "description": "Execute a SQL query against the database and return the result rows",
    "parameters": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": "The SQL SELECT query to execute"
            },
            "database": {
                "type": "string",
                "description": "Name of the target database schema"
            }
        },
        "required": ["query", "database"]
    }
}"""

# File operations handler
read_file_handler = """You are a file system assistant. You should use this tool to read file contents when the user requests it.

{
    "type": "function",
    "function": {
        "name": "read_file",
        "description": "Read the contents of a file from the local filesystem",
        "parameters": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Absolute or relative path to the file to read"
                },
                "encoding": {
                    "type": "string",
                    "description": "File encoding to use (default utf-8)"
                }
            },
            "required": ["path"]
        }
    }
}"""

# Grouped tools list for easy registration
tools = [get_weather_tool, web_search_skill, execute_code_function, query_database_action, read_file_handler]

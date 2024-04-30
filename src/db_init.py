# Packages
import os
from dotenv import load_dotenv, dotenv_values

# Setup
load_dotenv()
DB_USER = os.getenv("DB_USER")
DEFAULT_DB = os.getenv("DEFAULT_DB")
DB_PASSWORD = os.getenv("DB_PASSWORD")
HOST = os.getenv("HOST")
PORT = os.getenv("PORT")
INIT_QUERY_FILE = "init_query.sql"
PSQL_STRING = f"psql -Atx postgresql://{DB_USER}:{DB_PASSWORD}@{HOST}:{PORT}/{DEFAULT_DB} -w < {INIT_QUERY_FILE}"

# Build DB and tables
os.system(PSQL_STRING)

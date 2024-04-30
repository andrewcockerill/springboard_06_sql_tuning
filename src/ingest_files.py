# Packages
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv
import logging
import re

# Constants
load_dotenv()
CHUNK_SIZE = 100000
DB_USER = os.getenv("DB_USER")
DB_NAME = "dblp"
DB_PASSWORD = os.getenv("DB_PASSWORD")
HOST = os.getenv("HOST")
PORT = os.getenv("PORT")
CONNECT_STRING = f"postgresql://{DB_USER}:{DB_PASSWORD}@{HOST}:{PORT}/{DB_NAME}"
FILE_FOLDER = "dataset"

# Logging
logger = logging.getLogger('ingest_files')
logger.setLevel(logging.INFO)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh = logging.FileHandler('../logs/ingest_files.log')
sh = logging.StreamHandler()
fh.setFormatter(formatter)
logger.addHandler(fh)
logger.addHandler(sh)
logger.info('application started')

# Setup engine
engine = create_engine(CONNECT_STRING, client_encoding='utf8')

# Ingest
filenames = [os.path.join(FILE_FOLDER, f) for f in os.listdir(
    FILE_FOLDER) if bool(re.search(r"\.csv$", f))]

logger.info('begin ingestion')
for csv in filenames:
    basename = re.sub(r"\.csv$", "", os.path.split(csv)[-1])
    logger.info(f'begin ingest of {basename}')
    try:
        for context_df in pd.read_csv(csv, dtype=str, chunksize=CHUNK_SIZE):
            context_df.to_sql(basename, con=engine,
                              if_exists="append", index=False)
            logger.info(f'appended {context_df.shape[0]} rows')
        logger.info(f'finished ingestion of {basename}')
    except Exception as e:
        logger.error(f'unexpected error during ingestion of {basename}')
        logger.error(e)
logger.info('finished')

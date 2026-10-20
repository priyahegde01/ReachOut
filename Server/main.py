# Temporary code for structure

from fastapi import FastAPI

app = FastAPI(title="ReachOut API")


@app.get("/")
def root():
    return {"message": "ReachOut API is up and running"}

@app.get("/health")
def health_check():
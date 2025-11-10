"""
Cognee API Server - Self-hosted deployment
This is the main entry point for the Cognee API when running as a standalone service.
"""
import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import cognee

# Configure logging
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    logger.info("Starting Cognee API server...")
    
    # Initialize Cognee
    try:
        await cognee.pregel.initialize()
        logger.info("Cognee initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Cognee: {e}")
    
    yield
    
    # Cleanup
    logger.info("Shutting down Cognee API server...")


# Initialize FastAPI app
app = FastAPI(
    title="Cognee API",
    description="Self-hosted Cognee API for AI memory and knowledge graph management",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Request/Response models
class AddDataRequest(BaseModel):
    data: str | List[str]
    dataset_name: Optional[str] = "default"


class SearchRequest(BaseModel):
    query: str
    mode: Optional[str] = "default"


class CognifyRequest(BaseModel):
    dataset_name: Optional[str] = "default"


# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for container orchestration"""
    return {"status": "healthy", "service": "cognee-api"}


@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "service": "Cognee API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "health": "/health"
    }


@app.post("/add")
async def add_data(request: AddDataRequest):
    """
    Add data to Cognee for processing.
    This prepares data for cognification.
    """
    try:
        data = request.data
        dataset_name = request.dataset_name
        
        logger.info(f"Adding data to dataset: {dataset_name}")
        
        # Add data using Cognee
        result = await cognee.add(data, dataset_name=dataset_name)
        
        return {
            "status": "success",
            "message": "Data added successfully",
            "dataset": dataset_name,
            "result": result
        }
    except Exception as e:
        logger.error(f"Error adding data: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/cognify")
async def cognify(request: CognifyRequest = None):
    """
    Process data and build knowledge graph.
    This creates the memory layer from added data.
    """
    try:
        dataset_name = request.dataset_name if request else "default"
        
        logger.info(f"Starting cognification for dataset: {dataset_name}")
        
        # Run cognification
        result = await cognee.cognify()
        
        return {
            "status": "success",
            "message": "Cognification completed",
            "dataset": dataset_name,
            "result": result
        }
    except Exception as e:
        logger.error(f"Error during cognification: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/search")
async def search(request: SearchRequest):
    """
    Search the knowledge graph with context.
    Combines vector similarity with graph traversal.
    """
    try:
        query = request.query
        mode = request.mode
        
        logger.info(f"Searching with query: {query}")
        
        # Perform search
        results = await cognee.search(query, mode=mode)
        
        return {
            "status": "success",
            "query": query,
            "mode": mode,
            "results": results
        }
    except Exception as e:
        logger.error(f"Error during search: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.delete("/reset")
async def reset():
    """
    Reset Cognee - clears all data and knowledge graphs.
    Use with caution!
    """
    try:
        logger.warning("Resetting Cognee - all data will be cleared!")
        
        await cognee.pregel.reset()
        
        return {
            "status": "success",
            "message": "Cognee has been reset"
        }
    except Exception as e:
        logger.error(f"Error during reset: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/status")
async def get_status():
    """Get current Cognee system status"""
    try:
        # You can extend this with actual status checks
        return {
            "status": "operational",
            "service": "cognee",
            "environment": os.getenv("COGNEE_ENV", "production"),
            "llm_provider": os.getenv("LLM_PROVIDER", "openai"),
            "vector_db": os.getenv("VECTOR_DB_PROVIDER", "qdrant"),
            "graph_db": os.getenv("GRAPH_DB_PROVIDER", "neo4j")
        }
    except Exception as e:
        logger.error(f"Error getting status: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    
    port = int(os.getenv("COGNEE_PORT", 8000))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=os.getenv("COGNEE_ENV") != "production"
    )


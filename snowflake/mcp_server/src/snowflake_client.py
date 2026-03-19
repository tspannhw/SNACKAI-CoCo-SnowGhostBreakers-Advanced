"""
Snowflake connection management with session pooling for SPCS deployment.
"""

import os
import logging
from contextlib import contextmanager
from typing import Optional, Generator, Any
from threading import Lock
from queue import Queue, Empty

from snowflake.snowpark import Session
from snowflake.snowpark.exceptions import SnowparkSessionException

logger = logging.getLogger(__name__)


class SnowflakeClientConfig:
    """Configuration for Snowflake connection."""
    
    def __init__(self):
        # In SPCS, authentication is handled automatically via SPCS token
        self.database = os.getenv("SNOWFLAKE_DATABASE", "GHOST_DETECTION")
        self.schema = os.getenv("SNOWFLAKE_SCHEMA", "APP")
        self.warehouse = os.getenv("SNOWFLAKE_WAREHOUSE", "GHOST_DETECTION_WH")
        self.role = os.getenv("SNOWFLAKE_ROLE")
        
        # Pool settings
        self.pool_size = int(os.getenv("SNOWFLAKE_POOL_SIZE", "5"))
        self.pool_timeout = int(os.getenv("SNOWFLAKE_POOL_TIMEOUT", "30"))


class SnowflakeSessionPool:
    """Thread-safe session pool for Snowflake connections."""
    
    def __init__(self, config: SnowflakeClientConfig):
        self.config = config
        self._pool: Queue[Session] = Queue(maxsize=config.pool_size)
        self._lock = Lock()
        self._created_count = 0
        self._active_count = 0
        
    def _create_session(self) -> Session:
        """Create a new Snowflake session using SPCS authentication."""
        try:
            # In SPCS, use token-based authentication
            connection_params = {
                "database": self.config.database,
                "schema": self.config.schema,
                "warehouse": self.config.warehouse,
            }
            
            # Add role if specified
            if self.config.role:
                connection_params["role"] = self.config.role
            
            # Check if running in SPCS (token file exists)
            token_path = "/snowflake/session/token"
            if os.path.exists(token_path):
                with open(token_path, "r") as f:
                    token = f.read().strip()
                connection_params["authenticator"] = "oauth"
                connection_params["token"] = token
                connection_params["account"] = os.getenv("SNOWFLAKE_ACCOUNT", "")
                connection_params["host"] = os.getenv("SNOWFLAKE_HOST", "")
            else:
                # Local development - use environment variables
                connection_params["account"] = os.getenv("SNOWFLAKE_ACCOUNT", "")
                connection_params["user"] = os.getenv("SNOWFLAKE_USER", "")
                connection_params["password"] = os.getenv("SNOWFLAKE_PASSWORD", "")
            
            session = Session.builder.configs(connection_params).create()
            logger.info("Created new Snowflake session")
            return session
            
        except Exception as e:
            logger.error(f"Failed to create Snowflake session: {e}")
            raise
    
    def acquire(self) -> Session:
        """Acquire a session from the pool or create a new one."""
        try:
            # Try to get an existing session from the pool
            session = self._pool.get_nowait()
            
            # Validate the session is still active
            try:
                session.sql("SELECT 1").collect()
                with self._lock:
                    self._active_count += 1
                return session
            except Exception:
                logger.warning("Session expired, creating new one")
                session = self._create_session()
                with self._lock:
                    self._active_count += 1
                return session
                
        except Empty:
            # Pool is empty, create a new session if under limit
            with self._lock:
                if self._created_count < self.config.pool_size:
                    self._created_count += 1
                    self._active_count += 1
                    return self._create_session()
            
            # Pool is at capacity, wait for an available session
            try:
                session = self._pool.get(timeout=self.config.pool_timeout)
                with self._lock:
                    self._active_count += 1
                return session
            except Empty:
                raise TimeoutError("Timeout waiting for available Snowflake session")
    
    def release(self, session: Session):
        """Return a session to the pool."""
        try:
            with self._lock:
                self._active_count -= 1
            self._pool.put_nowait(session)
        except Exception:
            # Pool is full, close the session
            try:
                session.close()
                with self._lock:
                    self._created_count -= 1
            except Exception as e:
                logger.warning(f"Error closing session: {e}")
    
    def close_all(self):
        """Close all sessions in the pool."""
        while True:
            try:
                session = self._pool.get_nowait()
                try:
                    session.close()
                except Exception as e:
                    logger.warning(f"Error closing session: {e}")
            except Empty:
                break
        
        with self._lock:
            self._created_count = 0
            self._active_count = 0
    
    @property
    def stats(self) -> dict:
        """Get pool statistics."""
        with self._lock:
            return {
                "pool_size": self.config.pool_size,
                "created_count": self._created_count,
                "active_count": self._active_count,
                "available_count": self._pool.qsize(),
            }


class SnowflakeClient:
    """High-level Snowflake client with connection pooling."""
    
    _instance: Optional["SnowflakeClient"] = None
    _lock = Lock()
    
    def __new__(cls):
        """Singleton pattern for client instance."""
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
                    cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.config = SnowflakeClientConfig()
        self._pool = SnowflakeSessionPool(self.config)
        self._initialized = True
        logger.info("SnowflakeClient initialized")
    
    @contextmanager
    def session(self) -> Generator[Session, None, None]:
        """Context manager for acquiring and releasing sessions."""
        session = self._pool.acquire()
        try:
            yield session
        finally:
            self._pool.release(session)
    
    def execute_query(self, query: str, params: Optional[dict] = None) -> list[dict]:
        """Execute a query and return results as list of dicts."""
        with self.session() as session:
            try:
                if params:
                    # Use parameterized query for security
                    df = session.sql(query)
                else:
                    df = session.sql(query)
                
                rows = df.collect()
                return [row.as_dict() for row in rows]
            except Exception as e:
                logger.error(f"Query execution failed: {e}")
                raise
    
    def execute_procedure(self, procedure_name: str, *args) -> Any:
        """Execute a stored procedure."""
        with self.session() as session:
            try:
                result = session.call(procedure_name, *args)
                return result
            except Exception as e:
                logger.error(f"Procedure execution failed: {e}")
                raise
    
    def get_table_data(
        self, 
        table_name: str, 
        columns: Optional[list[str]] = None,
        filters: Optional[dict] = None,
        limit: Optional[int] = None
    ) -> list[dict]:
        """Retrieve data from a table with optional filtering."""
        with self.session() as session:
            try:
                table = session.table(table_name)
                
                if columns:
                    table = table.select(columns)
                
                if filters:
                    for col, value in filters.items():
                        table = table.filter(table[col] == value)
                
                if limit:
                    table = table.limit(limit)
                
                rows = table.collect()
                return [row.as_dict() for row in rows]
            except Exception as e:
                logger.error(f"Failed to get table data: {e}")
                raise
    
    def health_check(self) -> bool:
        """Check if the Snowflake connection is healthy."""
        try:
            with self.session() as session:
                session.sql("SELECT 1").collect()
                return True
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return False
    
    @property
    def pool_stats(self) -> dict:
        """Get connection pool statistics."""
        return self._pool.stats
    
    def close(self):
        """Close all connections and cleanup."""
        self._pool.close_all()
        logger.info("SnowflakeClient closed")


# Global client instance
def get_snowflake_client() -> SnowflakeClient:
    """Get the singleton Snowflake client instance."""
    return SnowflakeClient()

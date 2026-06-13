BEGIN;

CREATE EXTENSION IF NOT EXISTS citus;
SELECT citus_set_coordinator_host('postgresql-coord', 5432);

-- Registrar workers solo si no existen
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_dist_node
    WHERE nodename = 'postgresql-worker1' AND nodeport = 5432
  ) THEN
    PERFORM citus_add_node('postgresql-worker1', 5432);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_dist_node
    WHERE nodename = 'postgresql-worker2' AND nodeport = 5432
  ) THEN
    PERFORM citus_add_node('postgresql-worker2', 5432);
  END IF;
END $$;

SELECT * FROM citus_get_active_worker_nodes();

COMMIT;



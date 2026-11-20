-- The databases beside auth, made when missing, so a stack whose volume predates
-- one of them gets it too. compose.yml runs this on a new volume, and
-- compose.all.yml's databases service on every start.
SELECT format('CREATE DATABASE %I', name)
FROM unnest(array['workbench', 'collab', 'agent_control', 'knowledge', 'console', 'automations', 'ai_gateway']) AS name
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = name)
\gexec
